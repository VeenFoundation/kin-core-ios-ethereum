#!/usr/bin/env bash

# create 10 accounts with balance 100 ETH each
balance=100000000000000000000

export ACCOUNT_0_PRIVATE_KEY=0x11c98b8fa69354b26b5db98148a5bc4ef2ebae8187f651b82409f6cefc9bb0b8
export ACCOUNT_1_PRIVATE_KEY=0xc5db67b3865454f6d129ec83204e845a2822d9fe5338ff46fe4c126859e1357e
export ACCOUNT_2_PRIVATE_KEY=0x6ac1a8c98fa298af3884406fbd9468dca5200898f065e1283fc85dff95646c25
export ACCOUNT_3_PRIVATE_KEY=0xbd9aebf18275f8074c53036818e8583b242f9bdfb7c0e79088007cb39a96e097
export ACCOUNT_4_PRIVATE_KEY=0x8b727508230fda8e0ec96b7c9e51c89ff0e41ba30fad221c2f0fe942158571b1
export ACCOUNT_5_PRIVATE_KEY=0x514111937962a290ba6afa3dd0044e0720148b46cd2dbc8045e811f8157b6b1a
export ACCOUNT_6_PRIVATE_KEY=0x52f21c3eedc184eb13fcd5ec8e45e6741d97bca85a8703d733fab9c19f5e8518
export ACCOUNT_7_PRIVATE_KEY=0xbca3035e18b3f87a38fa34fcc2561a023fe1f9b93354c04c772f37497ef08f3e
export ACCOUNT_8_PRIVATE_KEY=0x2d8676754eb3d184f3e9428c5d52eacdf1d507593ba50c3ef2a59e1a3a46b578
export ACCOUNT_9_PRIVATE_KEY=0xabf8c2dd52f5b14ea437325854048e5daadbca80f99f9d6f8e97ab5e05d4f0ab

account_array=( \
    $ACCOUNT_0_PRIVATE_KEY \
    $ACCOUNT_1_PRIVATE_KEY \
    $ACCOUNT_2_PRIVATE_KEY \
    $ACCOUNT_3_PRIVATE_KEY \
    $ACCOUNT_4_PRIVATE_KEY \
    $ACCOUNT_5_PRIVATE_KEY \
    $ACCOUNT_6_PRIVATE_KEY \
    $ACCOUNT_7_PRIVATE_KEY \
    $ACCOUNT_8_PRIVATE_KEY \
    $ACCOUNT_9_PRIVATE_KEY \
    )
