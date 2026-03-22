# gbl_root_canoe
root 8e5/8g5的设备，同时让系统认为BL锁定

ABL.efi:不含superfb，建议设备解锁时使用

ABL_with_superfastboot.efi:含superfb，建议设备锁定时使用

ABL 补丁1：让锁定时跳过错误
补丁2,强制向tee报告锁定，验证通过

因为补丁2存在，锁bl非必须，锁的好处是去除解锁提示

HYPER OS等有防回滚的系统不要锁bl，使用ABL.efi