import scipy.io as sio
import glob
import os
import random
import math
import h5py
import numpy as np
import tensorflow as tf
from tensorflow.keras.optimizers import Adam
from tensorflow.keras import Sequential
from tensorflow.keras.layers import Dropout, Dense, InputLayer
from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping
from tensorflow.keras.initializers import GlorotUniform
from tensorflow.keras.regularizers import l1, l2, l1_l2
from tensorflow.keras.models import load_model
import matplotlib.pyplot as plt
from focal_loss import BinaryFocalLoss
import mat73
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
import tensorflow.keras.backend as K
import sys

subject = sys.argv[1]
print('subject = ' + subject)

# define pipeline
over = SMOTE(sampling_strategy=0.1)
under = RandomUnderSampler(sampling_strategy=1)
steps = [('o', over), ('u', under)]
pipeline = Pipeline(steps=steps)

lr_rate = 1e-3
num_epoch = 200
batch_sz = 1024

folder="/mnt/beegfs/sut/MELD_SBM"

lossFcn='pyBCE_lr3_SMOTE'
Sets = ["SBM_LOO_v1", "SBM_nMRF_LOO_v1", "SBM_FLAIR_LOO_v1", "SBM_FLAIR_nMRF_LOO_v1"]

re_rate = 1e-2

def weighted_cross_entropy_loss(y_true, y_pred):
    return tf.nn.weighted_cross_entropy_with_logits(y_true, y_pred, pos_weight = pos_weight)

def DiceBCELoss(y_true, y_pred, smooth = 1e-6):
    y_true = K.flatten(y_true)
    y_pred = K.flatten(y_pred)

    BCE_obj = tf.keras.losses.BinaryCrossentropy(from_logits=True)
    BCE = BCE_obj(y_true, y_pred).numpy()
    intersection = K.sum(K.abs(y_true * y_pred), axis = -1)
    Dice_loss = 1 - (2*intersection + smooth) / (K.sum(y_true) + K.sum(y_pred) + smooth)
    DiceBCE = BCE + Dice_loss
    return DiceBCE

def get_net(X_train):
    model = Sequential()
    model.add(InputLayer(input_shape=(np.shape(X_train)[1],),
                         name='input'))
    #model.add(Dropout(0.4, name = 'dropout1'))
    model.add(Dense(40, activation='relu',
                    name = 'd1',
                    kernel_initializer=GlorotUniform))
    #model.add(Dropout(0.4,name = 'dropout2'))
    model.add(Dense(20, activation='relu',
                    name = 'd2',
                    kernel_initializer=GlorotUniform))
    model.add(Dense(10, activation='relu',
                    name = 'd3',
                    kernel_initializer=GlorotUniform))
    model.add(Dropout(0.4, name = 'dropout3'))
    model.add(Dense(1,
                    activation='sigmoid',
                    name = 'd4',
                    kernel_initializer=GlorotUniform))

    # Compile model
    model.compile(loss='binary_crossentropy', optimizer=Adam(learning_rate = lr_rate), metrics=['accuracy'])
    #model.compile(loss = DiceBCELoss, optimizer=Adam(learning_rate = lr_rate), metrics=['accuracy'], run_eagerly=True)
    #model.compile(loss=BinaryFocalLoss(gamma=5),
    #              optimizer=Adam(learning_rate = lr_rate),
    #              metrics=['accuracy'])
    #model.compile(loss=weighted_cross_entropy_loss, optimizer=Adam(learning_rate=lr_rate), metrics=['accuracy'])
    return model

def get_net_L1(X_train):
    model = Sequential()
    model.add(InputLayer(input_shape=(np.shape(X_train)[1],), 
                         name='input'))
    #model.add(Dropout(0.4, name = 'dropout1'))
    model.add(Dense(40, activation='relu', 
                    name = 'd1',  
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l1(re_rate)))
    #model.add(Dropout(0.4, name = 'dropout2'))
    model.add(Dense(20, activation='relu',
                    name = 'd2',
                    kernel_initializer=GlorotUniform,
                    kernel_regularizer=l1(re_rate)))
    model.add(Dense(10, activation='relu', 
                    name = 'd3',  
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l1(re_rate)))
    model.add(Dropout(0.4, name = 'dropout3'))
    model.add(Dense(1, 
                    activation='sigmoid', 
                    name = 'd4', 
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l1(re_rate)))
    
    # Compile model
    model.compile(loss='binary_crossentropy', optimizer=Adam(learning_rate = lr_rate), metrics=['accuracy'])
    #model.compile(loss = DiceBCELoss, optimizer=Adam(learning_rate = lr_rate), metrics=['accuracy'], run_eagerly=True)
    #model.compile(loss=BinaryFocalLoss(gamma=5), 
    #              optimizer=Adam(learning_rate = lr_rate), 
    #              metrics=['accuracy'])
    #model.compile(loss=weighted_cross_entropy_loss, optimizer=Adam(learning_rate=lr_rate), metrics=['accuracy'])
    return model

def get_net_L2(X_train):
    model = Sequential()
    model.add(InputLayer(input_shape=(np.shape(X_train)[1],), 
                         name='input'))
    #model.add(Dropout(0.4, name = 'dropout1'))
    model.add(Dense(40, activation='relu', 
                    name = 'd1',  
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l2(re_rate)))
    #model.add(Dropout(0.4, name = 'dropout2'))
    model.add(Dense(20, activation='relu',
                    name = 'd2',
                    kernel_initializer=GlorotUniform,
                    kernel_regularizer=l2(re_rate)))
    model.add(Dense(10, activation='relu', 
                    name = 'd3',  
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l2(re_rate)))
    model.add(Dropout(0.4, name = 'dropout3'))
    model.add(Dense(1, 
                    activation='sigmoid', 
                    name = 'd4', 
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l2(re_rate)))
    
    # Compile model
    model.compile(loss='binary_crossentropy', optimizer=Adam(learning_rate = lr_rate), metrics=['accuracy'])
    #model.compile(loss = DiceBCELoss, optimizer=Adam(learning_rate = lr_rate), metrics=['accuracy'], run_eagerly=True)
    #model.compile(loss=BinaryFocalLoss(gamma=5), 
    #              optimizer=Adam(learning_rate = lr_rate), 
    #              metrics=['accuracy'])
    #model.compile(loss=weighted_cross_entropy_loss, optimizer=Adam(learning_rate=lr_rate), metrics=['accuracy'])
    return model

def get_net_L1_L2(X_train):
    model = Sequential()
    model.add(InputLayer(input_shape=(np.shape(X_train)[1],), 
                         name='input'))
    #model.add(Dropout(0.4, name = 'dropout1'))
    model.add(Dense(40, activation='relu', 
                    name = 'd1',  
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l1_l2(l1=re_rate[0], l2=re_rate[1])))
    #model.add(Dropout(0.4, name = 'dropout2'))
    model.add(Dense(20, activation='relu',
                    name = 'd2',
                    kernel_initializer=GlorotUniform,
                    kernel_regularizer=l1_l2(l1=re_rate[0], l2=re_rate[1])))
    model.add(Dense(10, activation='relu', 
                    name = 'd3',  
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l1_l2(l1=re_rate[0], l2=re_rate[1])))
    model.add(Dropout(0.4, name = 'dropout3'))
    model.add(Dense(1, 
                    activation='sigmoid', 
                    name = 'd4', 
                    kernel_initializer=GlorotUniform, 
                    kernel_regularizer=l1_l2(l1=re_rate[0], l2=re_rate[1])))
    
    # Compile model
    model.compile(loss='binary_crossentropy', optimizer=Adam(learning_rate = lr_rate), metrics=['accuracy'])
    #model.compile(loss = DiceBCELoss, optimizer=Adam(learning_rate = lr_rate), metrics=['accuracy'], run_eagerly=True)
    #model.compile(loss=BinaryFocalLoss(gamma=5), 
    #              optimizer=Adam(learning_rate = lr_rate), 
    #              metrics=['accuracy'])
    #model.compile(loss=weighted_cross_entropy_loss, optimizer=Adam(learning_rate=lr_rate), metrics=['accuracy'])
    return model

for idx in range(len(Sets)):
    Set = Sets[idx]
    print(lossFcn+ " + "+Set+" + "+subject)

    outweight_fn = lossFcn + ".hdf5"
    model_checkpoint = ModelCheckpoint(filepath = os.path.join(folder, Set, subject, outweight_fn), monitor='loss', mode = 'min', save_best_only = True)
    model_earlystopping = EarlyStopping(monitor = 'loss', patience = 20, mode = 'min')

    print("=====================load training data=========================")
    mat = mat73.loadmat(os.path.join(folder, Set, subject, "Train_data.mat"))
    X_train = mat['X_train']
    Y_train = mat['Y_train']
    Y_train = Y_train[:, 1]
    del mat

    print("=======================SMOTE processing=========================")
    X_train, Y_train = pipeline.fit_resample(X_train, Y_train)
    print(X_train.shape)
    pos_weight = np.argwhere(Y_train == 0).shape[0] / np.argwhere(Y_train == 1).shape[0]
    print(pos_weight)

    model = get_net(X_train);

    history = model.fit(X_train, 
                Y_train, 
                epochs = num_epoch, 
                batch_size = batch_sz, 
                callbacks = [model_checkpoint, model_earlystopping], 
                shuffle = True, 
                validation_split = 0.1,
                verbose = 2)

    model.save(os.path.join(folder, Set, subject, 'model_' + lossFcn + '.h5'))
    model.save_weights(os.path.join(folder, Set, subject, 'final_weight_' + lossFcn + '.h5'))

    print("=====================performance visualization=========================")
    # summarize history for accuracy
    plt.plot(history.history['accuracy'])
    plt.plot(history.history['val_accuracy'])
    plt.title('model accuracy')
    plt.ylabel('accuracy')
    plt.xlabel('epoch')
    plt.legend(['train', 'val'], loc='upper left')
    plt.savefig(os.path.join(folder, Set, subject, "Fig_acc_" + lossFcn + ".png"))
    plt.close()

    # summarize history for loss
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('loss')
    plt.xlabel('epoch')
    plt.legend(['train', 'val'], loc='upper left')
    plt.savefig(os.path.join(folder, Set, subject, "Fig_loss_" + lossFcn + ".png"))
    plt.close()

    print("=====================Test subjects=========================")
    Test_subjects = glob.glob(os.path.join(folder, Set, "Testsubject_PT", "P*sm.mat"))
    for Test_subject in Test_subjects:
        mat = mat73.loadmat(Test_subject)
        test_filename, test_file_extension = os.path.splitext(os.path.basename(Test_subject))
        X_test_lh = mat['X_test_lh']
        Y_test_lh = mat['Y_test_lh']
        Y_test_lh = Y_test_lh[:, 1]

        X_test_rh = mat['X_test_rh']
        Y_test_rh = mat['Y_test_rh']
        Y_test_rh = Y_test_rh[:, 1]
        del mat

        Y_predict_lh = model.predict(X_test_lh)
        Y_predict_rh = model.predict(X_test_rh)

        sio.savemat(os.path.join(folder, Set, subject, 'TestSub_' + test_filename + '_' + lossFcn + '.mat'),
            {"Y_predict_lh": Y_predict_lh,
             "Y_predict_rh": Y_predict_rh})

    del X_test_lh, Y_test_lh, X_test_rh, Y_test_rh
    del Y_predict_lh, Y_predict_rh, test_filename, test_file_extension
    del Test_subjects
    
    print("=====================HC subjects=========================")
    HC_subjects = glob.glob(os.path.join(folder, Set, "Testsubject_HC", "V*sm_data.mat"))
    for HC_subject in HC_subjects:
        mat = mat73.loadmat(HC_subject)
        HC_filename, HC_file_extension = os.path.splitext(os.path.basename(HC_subject))
        X_test_lh = mat['X_test_lh']
        Y_test_lh = mat['Y_test_lh']
        Y_test_lh = Y_test_lh[:, 1]

        X_test_rh = mat['X_test_rh']
        Y_test_rh = mat['Y_test_rh']
        Y_test_rh = Y_test_rh[:, 1]
        del mat

        Y_predict_lh = model.predict(X_test_lh)
        Y_predict_rh = model.predict(X_test_rh)

        sio.savemat(os.path.join(folder, Set, subject, 'HCSub_' + HC_filename + '_' + lossFcn + HC_file_extension),
            {"Y_predict_lh": Y_predict_lh,
             "Y_predict_rh": Y_predict_rh})

        del X_test_lh, Y_test_lh, X_test_rh, Y_test_rh, HC_filename, HC_file_extension
        del Y_predict_lh, Y_predict_rh
    del X_train, Y_train, pos_weight, model, history, outweight_fn, model_checkpoint, model_earlystopping
    del HC_subjects, Set 
