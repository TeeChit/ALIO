#! /vendor/bin/sh

# Copyright (c) 2021-2021, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# honor create for copy rfnvcust file from /odm to modem /share
# author by h00014854 for AR000FQGSK
# create time at 2021/07/02
#

ODM_RFNVCUST_VERSION_CONTENT=""
SHARE_RFNVCUST_VERSION_CONTENT=""

RF_PRODUCT_NAME=`cat /proc/device-tree/rootparam/qcom,product_name`
ODM_RFNVCUST_PATH=/odm/etc/rfnvcust/${RF_PRODUCT_NAME}/
ODM_RFNVCUST_VERSION=${ODM_RFNVCUST_PATH}version.txt
if [ -f $ODM_RFNVCUST_VERSION ]; then
    ODM_RFNVCUST_VERSION_CONTENT=`cat $ODM_RFNVCUST_VERSION`
fi

COTA_RFNVCUST_PATH="/data/vendor/cota/para/ncfg_def/rfnv/${RF_PRODUCT_NAME}/"
COTA_VERSION_PATH="${COTA_RFNVCUST_PATH}/version"
COTA_VERSION_CONTENT=""

if [ -f $COTA_VERSION_PATH ]; then
    COTA_VERSION_CONTENT=`cat $COTA_VERSION_PATH`
fi

if [[ -z "$COTA_VERSION_CONTENT" && -z "$ODM_RFNVCUST_VERSION_CONTENT" ]]; then
    # no need to copy rfnv, exit
    exit 0;
fi

if [[ "$COTA_VERSION_CONTENT" > "$ODM_RFNVCUST_VERSION_CONTENT" ]]; then
    ODM_RFNVCUST_PATH=${COTA_RFNVCUST_PATH}
    ODM_RFNVCUST_VERSION_CONTENT=${COTA_VERSION_CONTENT}
fi

# Change group and dac permission
chown vendor_rfs.root /mnt/vendor/persist/rfs
chmod 0770 /mnt/vendor/persist/rfs
chown vendor_rfs.root /mnt/vendor/persist/rfs/shared
chmod 0770 /mnt/vendor/persist/rfs/shared/
chown vendor_rfs.root /mnt/vendor/persist/rfs/shared/rfnvcust
chmod 0770 /mnt/vendor/persist/rfs/shared/rfnvcust/
chown vendor_rfs.root /mnt/vendor/persist/rfs/shared/rfnvcust/product_name.txt
chmod 0770 /mnt/vendor/persist/rfs/shared/rfnvcust/product_name.txt
chown vendor_rfs.root /mnt/vendor/persist/rfs/shared/rfnvcust/${RF_PRODUCT_NAME}
chmod 0770 /mnt/vendor/persist/rfs/shared/rfnvcust/${RF_PRODUCT_NAME}
# no sub-directory exist in RF_PRODUCT_NAME, so -R won't permission deny
chown -R vendor_rfs.root /mnt/vendor/persist/rfs/shared/rfnvcust/${RF_PRODUCT_NAME}/
chmod -R 0770 /mnt/vendor/persist/rfs/shared/rfnvcust/${RF_PRODUCT_NAME}/

SHARE_RFNVCUST_PATH=/mnt/vendor/persist/rfs/shared/rfnvcust/${RF_PRODUCT_NAME}/
SHARE_RFNVCUST_VERSION=${SHARE_RFNVCUST_PATH}version.txt
if [ ! -d $SHARE_RFNVCUST_PATH ]; then
    mkdir -p $SHARE_RFNVCUST_PATH
fi
if [ -f $SHARE_RFNVCUST_VERSION ]; then
    SHARE_RFNVCUST_VERSION_CONTENT=`cat $SHARE_RFNVCUST_VERSION`
fi

# Compare odm/etc/<product-name>/version.txt with /mnt/vendor/persist/rfnvcust/<product name>/version.txt
if [ "$ODM_RFNVCUST_VERSION_CONTENT" != "$SHARE_RFNVCUST_VERSION_CONTENT" ]; then
    NEED_COPY=true
else
    if [[ -n "$ODM_RFNVCUST_VERSION_CONTENT" && ! -f /mnt/vendor/persist/rfs/shared/rfnvcust/product_name.txt ]]; then
        # odm/rfnvcust exit but last copy didn't finished, retry again
        NEED_COPY=true
    fi
fi

if [ "$NEED_COPY" == true ];then
    rm -rf /mnt/vendor/persist/rfs/shared/rfnvcust/${RF_PRODUCT_NAME}/*
    rm -f /mnt/vendor/persist/rfs/shared/rfnvcust/product_name.txt
    # odm version content not empty, copy rfnvcust and create product-name file
    if [ -n "$ODM_RFNVCUST_VERSION_CONTENT" ]; then
        cp -dr ${ODM_RFNVCUST_PATH}* ${SHARE_RFNVCUST_PATH} && \
        echo -n $RF_PRODUCT_NAME > /mnt/vendor/persist/rfs/shared/rfnvcust/product_name.txt
    fi

    # mv cota rfnv file version to version.txt
    if [[ -f ${SHARE_RFNVCUST_PATH}/version && ! -f ${SHARE_RFNVCUST_PATH}/version.txt ]]; then
        chmod 0770 ${SHARE_RFNVCUST_PATH}/version
        cp ${SHARE_RFNVCUST_PATH}/version ${SHARE_RFNVCUST_PATH}/version.txt
        rm -f ${SHARE_RFNVCUST_PATH}/version
    fi
fi

# Recovery group and dac permission
chown -R vendor_rfs.vendor_rfs /mnt/vendor/persist/rfs/shared/rfnvcust/${RF_PRODUCT_NAME}/
chown vendor_rfs.vendor_rfs /mnt/vendor/persist/rfs/shared/rfnvcust/product_name.txt
chmod 0700 /mnt/vendor/persist/rfs/shared/rfnvcust
chown vendor_rfs.vendor_rfs /mnt/vendor/persist/rfs/shared/rfnvcust
chmod 0700 /mnt/vendor/persist/rfs/shared
chown vendor_rfs.vendor_rfs /mnt/vendor/persist/rfs/shared
chmod 0700 /mnt/vendor/persist/rfs
chown vendor_rfs.vendor_rfs /mnt/vendor/persist/rfs
