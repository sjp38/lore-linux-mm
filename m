Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36C666B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:54:22 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u126so1881509oia.19
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:54:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k8sor1054020oif.23.2017.12.13.16.54.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 16:54:20 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
Date: Wed, 13 Dec 2017 16:54:17 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

Hi,

Fedora got a bug report https://bugzilla.redhat.com/show_bug.cgi?id=1520982
of a boot failure/bug on Linus' master (full bootlog at the bugzilla)

WARNING: CPU: 3 PID: 3486 at block/genhd.c:680 device_add_disk+0x3d9/0x460
Modules linked in: intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp qcaux snd_usb_audio snd_usbmidi_lib coretemp floppy(+) snd_rawmidi snd_seq_device cdc_acm kvm_intel kvm irqbypass iTCO_wdt iTCO_vendor_support mei_wdt intel_wmi_thunderbolt intel_cstate intel_uncore intel_rapl_perf dcdbas snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic dell_smm_hwmon i2c_i801 snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep lpc_ich mei_me mei wmi shpchp target_core_mod snd_pcm_oss snd_mixer_oss binfmt_misc dm_crypt raid1 radeon i2c_algo_bit drm_kms_helper crct10dif_pclmul crc32_pclmul crc32c_intel ttm ghash_clmulni_intel drm e1000e ptp pps_core snd_pcm snd_timer snd soundcore analog gameport joydev
CPU: 3 PID: 3486 Comm: mdadm Not tainted 4.15.0-0.rc2.git0.1.fc28.x86_64 #1
Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
task: 00000000e8461579 task.stack: 00000000bfe85ee4
RIP: 0010:device_add_disk+0x3d9/0x460
RSP: 0018:ffffb42783b37b30 EFLAGS: 00010282
RAX: 00000000fffffff4 RBX: ffff952df829b000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 000000000001f040 RDI: 00000000000001ff
RBP: ffff952df829b070 R08: ffff952df6bb2d60 R09: 00000001820001ff
R10: 0000000000000001 R11: 0000000000001401 R12: 0000000000000000
R13: ffff952df829b00c R14: 0000000000000009 R15: ffff952df829b000
FS:  00007fd492882740(0000) GS:ffff952e1fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fd4921a95b0 CR3: 0000000837ecf001 CR4: 00000000001606e0
Call Trace:
  ? pm_runtime_init+0xa0/0xc0
  md_alloc+0x1a8/0x360
  md_probe+0x15/0x20
  kobj_lookup+0x100/0x150
  ? md_alloc+0x360/0x360
  get_gendisk+0x29/0x110
  blkdev_get+0x61/0x2f0
  ? bd_acquire+0xb0/0xb0
  ? bd_acquire+0xb0/0xb0
  do_dentry_open+0x1b1/0x2d0
  ? security_inode_permission+0x3c/0x50
  path_openat+0x602/0x14e0
  do_filp_open+0x9b/0x110
  ? __check_object_size+0xaf/0x1b0
  ? do_sys_open+0x1bd/0x250
  do_sys_open+0x1bd/0x250
  do_syscall_64+0x61/0x170
  entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7fd492234a5e
RSP: 002b:00007fff5d59e9f0 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
RAX: ffffffffffffffda RBX: 0000000000004082 RCX: 00007fd492234a5e
RDX: 0000000000004082 RSI: 00007fff5d59ea80 RDI: 00000000ffffff9c
RBP: 00007fff5d59ea80 R08: 00007fff5d59ea80 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000009
R13: 000000000000007c R14: 00007fff5d59eae0 R15: 00007fff5d59eb68
Code: 48 83 c6 10 e8 19 08 f0 ff 85 c0 0f 84 d6 fd ff ff 0f ff e9 cf fd ff ff 80 a3 bc 00 00 00 ef e9 c3 fd ff ff 0f ff e9 d8 fd ff ff <0f> ff e9 ba fe ff ff 31 f6 48 89 df e8 36 ec ff ff 48 85 c0 48
---[ end trace 9590c1ef4c38eb03 ]---
BUG: unable to handle kernel NULL pointer dereference at 0000000054605537
IP: sysfs_do_create_link_sd.isra.2+0x2f/0xb0
PGD 0 P4D 0
Oops: 0000 [#1] SMP
Modules linked in: intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp qcaux snd_usb_audio snd_usbmidi_lib coretemp floppy(+) snd_rawmidi snd_seq_device cdc_acm kvm_intel kvm irqbypass iTCO_wdt iTCO_vendor_support mei_wdt intel_wmi_thunderbolt intel_cstate intel_uncore intel_rapl_perf dcdbas snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic dell_smm_hwmon i2c_i801 snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep lpc_ich mei_me mei wmi shpchp target_core_mod snd_pcm_oss snd_mixer_oss binfmt_misc dm_crypt raid1 radeon i2c_algo_bit drm_kms_helper crct10dif_pclmul crc32_pclmul crc32c_intel ttm ghash_clmulni_intel drm e1000e ptp pps_core snd_pcm snd_timer snd soundcore analog gameport joydev
CPU: 3 PID: 3486 Comm: mdadm Tainted: G        W        4.15.0-0.rc2.git0.1.fc28.x86_64 #1
Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
task: 00000000e8461579 task.stack: 00000000bfe85ee4
RIP: 0010:sysfs_do_create_link_sd.isra.2+0x2f/0xb0
RSP: 0018:ffffb42783b37b00 EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000040 RCX: 0000000000000001
RDX: 0000000000000001 RSI: 0000000000000040 RDI: ffffffffbb613b0c
RBP: ffffffffbaca3577 R08: 0000000800000000 R09: 00000008ffffffff
R10: fffff9efe0e8ca00 R11: fffff9efe0d77001 R12: 0000000000000001
R13: ffff952df6f45110 R14: 0000000000000009 R15: ffff952df829b000
FS:  00007fd492882740(0000) GS:ffff952e1fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000040 CR3: 0000000837ecf001 CR4: 00000000001606e0
Call Trace:
  device_add_disk+0x3b7/0x460
  md_alloc+0x1a8/0x360
  md_probe+0x15/0x20
  kobj_lookup+0x100/0x150
  ? md_alloc+0x360/0x360
  get_gendisk+0x29/0x110
  blkdev_get+0x61/0x2f0
  ? bd_acquire+0xb0/0xb0
  ? bd_acquire+0xb0/0xb0
  do_dentry_open+0x1b1/0x2d0
  ? security_inode_permission+0x3c/0x50
  path_openat+0x602/0x14e0
  do_filp_open+0x9b/0x110
  ? __check_object_size+0xaf/0x1b0
  ? do_sys_open+0x1bd/0x250
  do_sys_open+0x1bd/0x250
  do_syscall_64+0x61/0x170
  entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7fd492234a5e
RSP: 002b:00007fff5d59e9f0 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
RAX: ffffffffffffffda RBX: 0000000000004082 RCX: 00007fd492234a5e
RDX: 0000000000004082 RSI: 00007fff5d59ea80 RDI: 00000000ffffff9c
RBP: 00007fff5d59ea80 R08: 00007fff5d59ea80 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000009
R13: 000000000000007c R14: 00007fff5d59eae0 R15: 00007fff5d59eb68
Code: 00 48 85 d2 41 56 41 55 41 54 55 53 74 76 48 85 ff 74 71 48 89 f3 49 89 fd 48 c7 c7 0c 3b 61 bb 41 89 cc 48 89 d5 e8 31 88 58 00 <48> 8b 1b 48 85 db 74 3c 48 89 df e8 71 c7 ff ff c6 05 36 bc 30
RIP: sysfs_do_create_link_sd.isra.2+0x2f/0xb0 RSP: ffffb42783b37b00
CR2: 0000000000000040
Dec 05 08:24:29 cerberus.csd.uwm.edu kernel: ---[ end trace 9590c1ef4c38eb04 ]---

The reporter did a bisect and found the bad commit to be

commit a0747a859ef6d3cc5b6cd50eb694499b78dd0025
Author: weiping zhang <zhangweiping@didichuxing.com>
Date:   Fri Nov 17 23:06:04 2017 +0800

     bdi: add error handle for bdi_debug_register
     
     In order to make error handle more cleaner we call bdi_debug_register
     before set state to WB_registered, that we can avoid call bdi_unregister
     in release_bdi().
     
     Reviewed-by: Jan Kara <jack@suse.cz>
     Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
     Signed-off-by: Jens Axboe <axboe@kernel.dk>

Any ideas?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
