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
# honor create for copy cota ncfg file from /data/vendor/cota/para/ncfg_def to modem /share
# author by d00024034
# create time at 2022/05/27
#

result=0
RFS_NCFG_PATH=/mnt/vendor/persist/rfs/shared/ncfg_def
RF_PRODUCT_NAME=`cat /proc/device-tree/rootparam/qcom,product_name`

copy_cota_ncfg_file() {
    # change group and dac permission
    chown vendor_rfs.root /mnt/vendor/persist/rfs
    chmod 0770 /mnt/vendor/persist/rfs
    chown vendor_rfs.root /mnt/vendor/persist/rfs/shared
    chmod 0770 /mnt/vendor/persist/rfs/shared

    if [ ! -d $RFS_NCFG_PATH ]; then
        mkdir -p $RFS_NCFG_PATH
    fi
    chown vendor_rfs.root ${RFS_NCFG_PATH}
    chmod -R 0770 ${RFS_NCFG_PATH}
    chown vendor_rfs.root ${RFS_NCFG_PATH}/swmbn
    chmod -R 0770 ${RFS_NCFG_PATH}/swmbn
    chown vendor_rfs.root ${RFS_NCFG_PATH}/hwmbn
    chmod -R 0770 ${RFS_NCFG_PATH}/hwmbn
    chown vendor_rfs.root ${RFS_NCFG_PATH}/rfnv
    chmod -R 0770 ${RFS_NCFG_PATH}/rfnv
    chown vendor_rfs.root ${RFS_NCFG_PATH}/rfnv/${RF_PRODUCT_NAME}
    chmod -R 0770 ${RFS_NCFG_PATH}/rfnv/${RF_PRODUCT_NAME}

    # copy ncfg files
    rm -rf ${RFS_NCFG_PATH}/*
    cp -dr /data/vendor/cota/para/ncfg_def/* ${RFS_NCFG_PATH}/

    # recovery group and dac permission
    chmod -R 0770 ${RFS_NCFG_PATH}
    chown -hR vendor_rfs.vendor_rfs ${RFS_NCFG_PATH}
    chmod 0700 /mnt/vendor/persist/rfs/shared
    chown vendor_rfs.vendor_rfs /mnt/vendor/persist/rfs/shared
    chmod 0700 /mnt/vendor/persist/rfs
    chown vendor_rfs.vendor_rfs /mnt/vendor/persist/rfs

    result=1
}

odm_version_content=""
if [ -f /odm/etc/ncfg_def/version.txt ]; then
    odm_version_content=`head -n 1 /odm/etc/ncfg_def/version.txt`
fi

cota_version_content=""
if [ -f /data/vendor/cota/para/ncfg_def/version.txt ]; then
    cota_version_content=`head -n 1 /data/vendor/cota/para/ncfg_def/version.txt`
fi

# check if need to copy
if [[ "$cota_version_content" > "$odm_version_content" ]]; then
    copy_cota_ncfg_file;
else
    # no need to copy
    result=2;
fi

# set copy complete result
if [ ! -f /data/vendor/radio/cota_qcom_ncfg_copy_complete ]; then
    echo $result > /data/vendor/radio/cota_qcom_ncfg_copy_complete
    chown radio.radio /data/vendor/radio/cota_qcom_ncfg_copy_complete
    chmod 0660 /data/vendor/radio/cota_qcom_ncfg_copy_complete
else
    echo $result > /data/vendor/radio/cota_qcom_ncfg_copy_complete
fi

