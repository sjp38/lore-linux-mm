Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A84765F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 09:14:40 -0400 (EDT)
Received: by ti-out-0910.google.com with SMTP id a21so1042778tia.8
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 06:14:41 -0700 (PDT)
Date: Sun, 19 Apr 2009 21:14:13 +0800
From: Ming Lei <tom.leiming@gmail.com>
Subject: [2.6.30-rc2 kswapd] lockdep warning: possible irq lock inversion
 dependency detected
Message-ID: <20090419211413.0c07d917@linux-lm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Hi,all

The following lockdep warning is found occasionally and has a very low
frequency.

Thanks.


[ 3256.533469] =========================================================
[ 3256.533474] [ INFO: possible irq lock inversion dependency detected ]
[ 3256.533478] 2.6.30-rc2 #94
[ 3256.533480] ---------------------------------------------------------
[ 3256.533484] kswapd0/449 just changed the state of lock:
[ 3256.533487]  (iprune_mutex){+.+.-.}, at: [<ffffffff802db9e7>]
shrink_icache_memory+0x45/0x255 [ 3256.533498] but this lock took
another, RECLAIM_FS-unsafe lock in the past: [ 3256.533501]
(&inode->inotify_mutex){+.+.+.} [ 3256.533505] 
[ 3256.533505] and interrupts could create inverse lock ordering
between them. [ 3256.533507] 
[ 3256.533509] 
[ 3256.533510] other info that might help us debug this:
[ 3256.533513] 1 lock held by kswapd0/449:
[ 3256.533516]  #0:  (shrinker_rwsem){++++..}, at: [<ffffffff8029fc8d>]
shrink_slab+0x38/0x188 [ 3256.533526] 
[ 3256.533527] the first lock's dependencies:
[ 3256.533529] -> (iprune_mutex){+.+.-.} ops: 19 {
[ 3256.533536]    HARDIRQ-ON-W at:
[ 3256.533540]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.533547]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.533553]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.533561]
[<ffffffff802dbc33>] invalidate_inodes+0x3c/0x137
[ 3256.533566]
[<ffffffff802edeaf>] __invalidate_device+0x30/0x4e
[ 3256.533572]
[<ffffffff8034d652>] invalidate_partition+0x27/0x3d
[ 3256.533579]
[<ffffffff80316b2b>] del_gendisk+0x6e/0x121
[ 3256.533586]
[<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod]
[ 3256.533596]
[<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f [scsi_mod]
[ 3256.533615]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.533621]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.533626]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.533632]
[<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.533638]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.533653]
[<ffffffffa009da02>] scsi_forget_host+0x42/0x6a [scsi_mod]
[ 3256.533667]
[<ffffffffa00978b3>] scsi_remove_host+0x90/0x115 [scsi_mod]
[ 3256.533681]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.533695]
[<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24 [usb_storage]
[ 3256.533705]
[<ffffffffa000c030>] usb_unbind_interface+0x63/0xf3 [usbcore]
[ 3256.533726]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.533731]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.533736]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.533742]
[<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.533747]
[<ffffffffa00090c5>] usb_disable_device+0x106/0x182 [usbcore]
[ 3256.533764]
[<ffffffffa00039f3>] usb_disconnect+0xcf/0x148 [usbcore]
[ 3256.533779]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.533794]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.533800]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.533806]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.533812]    SOFTIRQ-ON-W
at: [ 3256.533815]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.533821]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.533826]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.533832]
[<ffffffff802dbc33>] invalidate_inodes+0x3c/0x137
[ 3256.533837]
[<ffffffff802edeaf>] __invalidate_device+0x30/0x4e
[ 3256.533843]
[<ffffffff8034d652>] invalidate_partition+0x27/0x3d
[ 3256.533848]
[<ffffffff80316b2b>] del_gendisk+0x6e/0x121
[ 3256.533854]
[<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod]
[ 3256.533861]
[<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f [scsi_mod]
[ 3256.533875]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.533880]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.533885]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.533891]
[<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.533896]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.533910]
[<ffffffffa009da02>] scsi_forget_host+0x42/0x6a [scsi_mod]
[ 3256.533924]
[<ffffffffa00978b3>] scsi_remove_host+0x90/0x115 [scsi_mod]
[ 3256.533938]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.533948]
[<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24 [usb_storage]
[ 3256.533958]
[<ffffffffa000c030>] usb_unbind_interface+0x63/0xf3 [usbcore]
[ 3256.533974]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.533979]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.533984]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.533990]
[<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.533995]
[<ffffffffa00090c5>] usb_disable_device+0x106/0x182 [usbcore]
[ 3256.534011]
[<ffffffffa00039f3>] usb_disconnect+0xcf/0x148 [usbcore]
[ 3256.534026]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534041]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534046]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534051]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534056]
IN-RECLAIM_FS-W at:
[ 3256.534059]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534065]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534071]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534076]
[<ffffffff802db9e7>] shrink_icache_memory+0x45/0x255
[ 3256.534082]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534088]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534093]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534097]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534102]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534108]    INITIAL USE
at: [ 3256.534111]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534116]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534122]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534127]
[<ffffffff802dbc33>] invalidate_inodes+0x3c/0x137
[ 3256.534132]
[<ffffffff802edeaf>] __invalidate_device+0x30/0x4e
[ 3256.534138]
[<ffffffff8034d652>] invalidate_partition+0x27/0x3d
[ 3256.534144]
[<ffffffff80316b2b>] del_gendisk+0x6e/0x121
[ 3256.534149]
[<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod]
[ 3256.534156]
[<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f [scsi_mod]
[ 3256.534170]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534176]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534181]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534186]
[<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534191]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.534206]
[<ffffffffa009da02>] scsi_forget_host+0x42/0x6a [scsi_mod]
[ 3256.534219]
[<ffffffffa00978b3>] scsi_remove_host+0x90/0x115 [scsi_mod]
[ 3256.534233]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.534243]
[<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24 [usb_storage]
[ 3256.534253]
[<ffffffffa000c030>] usb_unbind_interface+0x63/0xf3 [usbcore]
[ 3256.534257]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534257]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534257]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534257]
[<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534257]
[<ffffffffa00090c5>] usb_disable_device+0x106/0x182 [usbcore]
[ 3256.534257]
[<ffffffffa00039f3>] usb_disconnect+0xcf/0x148 [usbcore]
[ 3256.534257]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]  }
[ 3256.534257]  ... key      at: [<ffffffff806133c0>]
iprune_mutex+0x70/0xb0 [ 3256.534257]  -> (inode_lock){+.+.-.} ops:
128828 { [ 3256.534257]     HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802db379>] ifind_fast+0x22/0x9d
[ 3256.534257]
[<ffffffff802dc2fa>] iget_locked+0x39/0x171
[ 3256.534257]
[<ffffffff80319b94>] sysfs_get_inode+0x1a/0x1f3
[ 3256.534257]
[<ffffffff8031c307>] sysfs_fill_super+0x51/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     SOFTIRQ-ON-W
at: [ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802db379>] ifind_fast+0x22/0x9d
[ 3256.534257]
[<ffffffff802dc2fa>] iget_locked+0x39/0x171
[ 3256.534257]
[<ffffffff80319b94>] sysfs_get_inode+0x1a/0x1f3
[ 3256.534257]
[<ffffffff8031c307>] sysfs_fill_super+0x51/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80354aa0>] _atomic_dec_and_lock+0x34/0x54
[ 3256.534257]
[<ffffffff802daf10>] iput+0x2f/0x65
[ 3256.534257]
[<ffffffff8031b5ba>] sysfs_d_iput+0x2f/0x34
[ 3256.534257]
[<ffffffff802d81a8>] dentry_iput+0x9f/0xc1
[ 3256.534257]
[<ffffffff802d82af>] d_kill+0x40/0x60
[ 3256.534257]
[<ffffffff802d8574>] __shrink_dcache_sb+0x2a5/0x33d
[ 3256.534257]
[<ffffffff802d86fd>] shrink_dcache_memory+0xf1/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802db379>] ifind_fast+0x22/0x9d
[ 3256.534257]
[<ffffffff802dc2fa>] iget_locked+0x39/0x171
[ 3256.534257]
[<ffffffff80319b94>] sysfs_get_inode+0x1a/0x1f3
[ 3256.534257]
[<ffffffff8031c307>] sysfs_fill_super+0x51/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]   }
[ 3256.534257]   ... key      at: [<ffffffff806132f8>]
inode_lock+0x18/0x40 [ 3256.534257]  ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802dbc3f>] invalidate_inodes+0x48/0x137 [ 3256.534257]
[<ffffffff802edeaf>] __invalidate_device+0x30/0x4e [ 3256.534257]
[<ffffffff8034d652>] invalidate_partition+0x27/0x3d [ 3256.534257]
[<ffffffff80316b2b>] del_gendisk+0x6e/0x121 [ 3256.534257]
[<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod] [ 3256.534257]
[<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f [scsi_mod]
[ 3256.534257]    [<ffffffff803d2ce8>]
__device_release_driver+0x80/0xa5 [ 3256.534257]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b [ 3256.534257]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd [ 3256.534257]
[<ffffffff803d066e>] device_del+0x138/0x177 [ 3256.534257]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.534257]    [<ffffffffa009da02>] scsi_forget_host+0x42/0x6a
[scsi_mod] [ 3256.534257]    [<ffffffffa00978b3>]
scsi_remove_host+0x90/0x115 [scsi_mod] [ 3256.534257]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.534257]    [<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24
[usb_storage] [ 3256.534257]    [<ffffffffa000c030>]
usb_unbind_interface+0x63/0xf3 [usbcore] [ 3256.534257]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534257]    [<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534257]    [<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534257]    [<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534257]    [<ffffffffa00090c5>] usb_disable_device+0x106/0x182
[usbcore] [ 3256.534257]    [<ffffffffa00039f3>]
usb_disconnect+0xcf/0x148 [usbcore] [ 3256.534257]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534257]    [<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]  -> (&inode->inotify_mutex){+.+.+.} ops:
20622 { [ 3256.534257]     HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f342a>] inotify_inode_is_dead+0x30/0x94
[ 3256.534257]
[<ffffffff802d818b>] dentry_iput+0x82/0xc1
[ 3256.534257]
[<ffffffff802d9c08>] d_delete+0x56/0xce
[ 3256.534257]
[<ffffffff802d1a68>] vfs_unlink+0xe7/0xfb
[ 3256.534257]
[<ffffffff802d3aa0>] do_unlinkat+0xcd/0x164
[ 3256.534257]
[<ffffffff802d3b48>] sys_unlink+0x11/0x13
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     SOFTIRQ-ON-W
at: [ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f342a>] inotify_inode_is_dead+0x30/0x94
[ 3256.534257]
[<ffffffff802d818b>] dentry_iput+0x82/0xc1
[ 3256.534257]
[<ffffffff802d9c08>] d_delete+0x56/0xce
[ 3256.534257]
[<ffffffff802d1a68>] vfs_unlink+0xe7/0xfb
[ 3256.534257]
[<ffffffff802d3aa0>] do_unlinkat+0xcd/0x164
[ 3256.534257]
[<ffffffff802d3b48>] sys_unlink+0x11/0x13
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
RECLAIM_FS-ON-W at:
[ 3256.534257]
[<ffffffff80265707>] mark_held_locks+0x4d/0x6b
[ 3256.534257]
[<ffffffff802657de>] lockdep_trace_alloc+0xb9/0xdb
[ 3256.534257]
[<ffffffff802c35db>] __kmalloc+0x70/0x27c
[ 3256.534257]
[<ffffffff802f43e2>] kernel_event+0xa7/0x10e
[ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]
[<ffffffff802f334a>] inotify_inode_queue_event+0xab/0xe0
[ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]
[<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a
[ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72
[ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f342a>] inotify_inode_is_dead+0x30/0x94
[ 3256.534257]
[<ffffffff802d818b>] dentry_iput+0x82/0xc1
[ 3256.534257]
[<ffffffff802d9c08>] d_delete+0x56/0xce
[ 3256.534257]
[<ffffffff802d1a68>] vfs_unlink+0xe7/0xfb
[ 3256.534257]
[<ffffffff802d3aa0>] do_unlinkat+0xcd/0x164
[ 3256.534257]
[<ffffffff802d3b48>] sys_unlink+0x11/0x13
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]   }
[ 3256.534257]   ... key      at: [<ffffffff8116cec0>]
__key.28886+0x0/0x8 [ 3256.534257]   -> (&ih->mutex){+.+.+.} ops: 3354
{ [ 3256.534257]      HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]
[<ffffffff802f406f>] sys_inotify_add_watch+0x19d/0x1a9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]
[<ffffffff802f406f>] sys_inotify_add_watch+0x19d/0x1a9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
RECLAIM_FS-ON-W at:
[ 3256.534257]
[<ffffffff80265707>] mark_held_locks+0x4d/0x6b
[ 3256.534257]
[<ffffffff802657de>] lockdep_trace_alloc+0xb9/0xdb
[ 3256.534257]
[<ffffffff802c35db>] __kmalloc+0x70/0x27c
[ 3256.534257]
[<ffffffff802f43e2>] kernel_event+0xa7/0x10e
[ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]
[<ffffffff802f334a>] inotify_inode_queue_event+0xab/0xe0
[ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]
[<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a
[ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72
[ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]
[<ffffffff802f406f>] sys_inotify_add_watch+0x19d/0x1a9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff8116d280>]
__key.20753+0x0/0x8 [ 3256.534257]    -> (&idp->lock){......} ops: 829
{ [ 3256.534257]       INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]
[<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]
[<ffffffff80320d40>] devpts_new_index+0x30/0xb0
[ 3256.534257]
[<ffffffff803b3056>] ptmx_open+0x29/0xef
[ 3256.534257]
[<ffffffff802cbbfc>] chrdev_open+0x197/0x1b8
[ 3256.534257]
[<ffffffff802c74fa>] __dentry_open+0x174/0x299
[ 3256.534257]
[<ffffffff802c76ec>] nameidata_to_filp+0x41/0x52
[ 3256.534257]
[<ffffffff802d4679>] do_filp_open+0x411/0x842
[ 3256.534257]
[<ffffffff802c72c2>] do_sys_open+0x53/0xda
[ 3256.534257]
[<ffffffff802c7372>] sys_open+0x1b/0x1d
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff8116fd30>]
__key.12838+0x0/0x8 [ 3256.534257]    ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]    [<ffffffff802f2dca>] inotify_handle_get_wd+0x24/0x65
[ 3256.534257]    [<ffffffff802f3014>] inotify_add_watch+0x5f/0x111
[ 3256.534257]    [<ffffffff802f3ff2>]
sys_inotify_add_watch+0x120/0x1a9 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    -> (&parent->list_lock){-.-.-.} ops: 477163
{ [ 3256.534257]       IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802c1460>] cache_flusharray+0x5a/0x10f
[ 3256.534257]
[<ffffffff802c0e0e>] kmem_cache_free+0x19e/0x244
[ 3256.534257]
[<ffffffff802e8251>] free_buffer_head+0x29/0x75
[ 3256.534257]
[<ffffffff802e8847>] try_to_free_buffers+0x8d/0xa4
[ 3256.534257]
[<ffffffffa0060c92>] journal_try_to_free_buffers+0x19a/0x1fc [jbd]
[ 3256.534257]
[<ffffffffa007d9cb>] bdev_try_to_free_page+0x5f/0x75 [ext3]
[ 3256.534257]
[<ffffffff802ee853>] blkdev_releasepage+0x31/0x3d
[ 3256.534257]
[<ffffffff802925ab>] try_to_release_page+0x32/0x3b
[ 3256.534257]
[<ffffffff8029ed2f>] shrink_page_list+0x529/0x736
[ 3256.534257]
[<ffffffff8029f5a7>] shrink_list+0x2aa/0x62a
[ 3256.534257]
[<ffffffff8029fbab>] shrink_zone+0x284/0x32e
[ 3256.534257]
[<ffffffff802a0553>] kswapd+0x4cc/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305
[ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c
[ 3256.534257]
[<ffffffff802c48a7>] kmem_cache_create+0x26c/0x535
[ 3256.534257]
[<ffffffff8069e371>] kmem_cache_init+0x1e6/0x688
[ 3256.534257]
[<ffffffff80684bf0>] start_kernel+0x303/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff8116c4a8>]
__key.25650+0x0/0x8 [ 3256.534257]     -> (&zone->lock){..-.-.} ops:
44576 { [ 3256.534257]        IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80297824>] free_pages_bulk+0x2d/0x2d4
[ 3256.534257]
[<ffffffff80298faf>] free_hot_cold_page+0x194/0x2c0
[ 3256.534257]
[<ffffffff80299104>] __pagevec_free+0x29/0x3d
[ 3256.534257]
[<ffffffff8029eddf>] shrink_page_list+0x5d9/0x736
[ 3256.534257]
[<ffffffff8029f5a7>] shrink_list+0x2aa/0x62a
[ 3256.534257]
[<ffffffff8029fbab>] shrink_zone+0x284/0x32e
[ 3256.534257]
[<ffffffff802a0553>] kswapd+0x4cc/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80297824>] free_pages_bulk+0x2d/0x2d4
[ 3256.534257]
[<ffffffff80298faf>] free_hot_cold_page+0x194/0x2c0
[ 3256.534257]
[<ffffffff80299133>] free_hot_page+0xb/0xd
[ 3256.534257]
[<ffffffff8029915b>] __free_pages+0x26/0x2f
[ 3256.534257]
[<ffffffff806b46c9>] __free_pages_bootmem+0x7e/0x80
[ 3256.534257]
[<ffffffff8069be44>] free_all_bootmem_core+0xf3/0x1c2
[ 3256.534257]
[<ffffffff8069bf3c>] free_all_bootmem_node+0x10/0x12
[ 3256.534257]
[<ffffffff80695ecf>] numa_free_all_bootmem+0x46/0x79
[ 3256.534257]
[<ffffffff80694fc7>] mem_init+0x1e/0x161
[ 3256.534257]
[<ffffffff80684bdc>] start_kernel+0x2ef/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff81169130>]
__key.31693+0x0/0x8 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     -> (&on_slab_l3_key){-.-.-.} ops:
30124 { [ 3256.534257]        IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802c1460>] cache_flusharray+0x5a/0x10f
[ 3256.534257]
[<ffffffff802c0e0e>] kmem_cache_free+0x19e/0x244
[ 3256.534257]
[<ffffffff802c100c>] slab_destroy+0x158/0x167
[ 3256.534257]
[<ffffffff802c1191>] free_block+0x176/0x1cb
[ 3256.534257]
[<ffffffff802c14a8>] cache_flusharray+0xa2/0x10f
[ 3256.534257]
[<ffffffff802c0e0e>] kmem_cache_free+0x19e/0x244
[ 3256.534257]
[<ffffffff802db890>] destroy_inode+0x43/0x47
[ 3256.534257]
[<ffffffff802dbe8f>] generic_delete_inode+0x161/0x173
[ 3256.534257]
[<ffffffff802daf42>] iput+0x61/0x65
[ 3256.534257]
[<ffffffff8031b5ba>] sysfs_d_iput+0x2f/0x34
[ 3256.534257]
[<ffffffff802d81a8>] dentry_iput+0x9f/0xc1
[ 3256.534257]
[<ffffffff802d82af>] d_kill+0x40/0x60
[ 3256.534257]
[<ffffffff802d8574>] __shrink_dcache_sb+0x2a5/0x33d
[ 3256.534257]
[<ffffffff802d86fd>] shrink_dcache_memory+0xf1/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305
[ 3256.534257]
[<ffffffff802c2d67>] kmem_cache_alloc_node_notrace+0x10e/0x191
[ 3256.534257]
[<ffffffff802c40a2>] do_tune_cpucache+0x375/0x504
[ 3256.534257]
[<ffffffff802c43bd>] enable_cpucache+0x60/0xa2
[ 3256.534257]
[<ffffffff804791d4>] setup_cpu_cache+0x24/0x2a9
[ 3256.534257]
[<ffffffff802c4afd>] kmem_cache_create+0x4c2/0x535
[ 3256.534257]
[<ffffffff806a3ea8>] idr_init_cache+0x1f/0x28
[ 3256.534257]
[<ffffffff80684bfa>] start_kernel+0x30d/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff8116c4d0>]
on_slab_l3_key+0x0/0x8 [ 3256.534257]      ... acquired at:
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c [ 3256.534257]
[<ffffffff80355941>] idr_pre_get+0x2d/0x75 [ 3256.534257]
[<ffffffff802f2dca>] inotify_handle_get_wd+0x24/0x65 [ 3256.534257]
[<ffffffff802f3014>] inotify_add_watch+0x5f/0x111 [ 3256.534257]
[<ffffffff802f3ff2>] sys_inotify_add_watch+0x120/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c20c5>] kmem_cache_alloc_node+0x112/0x214
[ 3256.534257]    [<ffffffff802c22ce>] cache_grow+0x107/0x3dc
[ 3256.534257]    [<ffffffff802c2859>] cache_alloc_refill+0x2b6/0x305
[ 3256.534257]    [<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c
[ 3256.534257]    [<ffffffff80355941>] idr_pre_get+0x2d/0x75
[ 3256.534257]    [<ffffffff802f2dca>] inotify_handle_get_wd+0x24/0x65
[ 3256.534257]    [<ffffffff802f3014>] inotify_add_watch+0x5f/0x111
[ 3256.534257]    [<ffffffff802f3ff2>]
sys_inotify_add_watch+0x120/0x1a9 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802dab9d>] igrab+0x18/0x40 [ 3256.534257]
[<ffffffff802f3040>] inotify_add_watch+0x8b/0x111 [ 3256.534257]
[<ffffffff802f3ff2>] sys_inotify_add_watch+0x120/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    -> (dcache_lock){+.+.-.} ops: 1141689
{ [ 3256.534257]       HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d9f1a>] d_alloc+0x18d/0x1de
[ 3256.534257]
[<ffffffff802d9f8a>] d_alloc_root+0x1f/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d9f1a>] d_alloc+0x18d/0x1de
[ 3256.534257]
[<ffffffff802d9f8a>] d_alloc_root+0x1f/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d8650>] shrink_dcache_memory+0x44/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d9f1a>] d_alloc+0x18d/0x1de
[ 3256.534257]
[<ffffffff802d9f8a>] d_alloc_root+0x1f/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff80676398>]
dcache_lock+0x18/0x40 [ 3256.534257]     -> (&dentry->d_lock){+.+.-.}
ops: 2150925 { [ 3256.534257]        HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802f2c0a>] inotify_d_instantiate+0x1b/0x49
[ 3256.534257]
[<ffffffff802d912a>] __d_instantiate+0x37/0x39
[ 3256.534257]
[<ffffffff802d9164>] d_instantiate+0x38/0x49
[ 3256.534257]
[<ffffffff802d9fb0>] d_alloc_root+0x45/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802f2c0a>] inotify_d_instantiate+0x1b/0x49
[ 3256.534257]
[<ffffffff802d912a>] __d_instantiate+0x37/0x39
[ 3256.534257]
[<ffffffff802d9164>] d_instantiate+0x38/0x49
[ 3256.534257]
[<ffffffff802d9fb0>] d_alloc_root+0x45/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d83b6>] __shrink_dcache_sb+0xe7/0x33d
[ 3256.534257]
[<ffffffff802d86fd>] shrink_dcache_memory+0xf1/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802f2c0a>] inotify_d_instantiate+0x1b/0x49
[ 3256.534257]
[<ffffffff802d912a>] __d_instantiate+0x37/0x39
[ 3256.534257]
[<ffffffff802d9164>] d_instantiate+0x38/0x49
[ 3256.534257]
[<ffffffff802d9fb0>] d_alloc_root+0x45/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff8116ce80>]
__key.28008+0x0/0x10 [ 3256.534257]      -> (sysctl_lock){+.+.-.} ops:
22882 { [ 3256.534257]         HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80248d45>] __sysctl_head_next+0x1f/0xd3
[ 3256.534257]
[<ffffffff8025cfb6>] sysctl_check_lookup+0xcd/0xf5
[ 3256.534257]
[<ffffffff8025d1ba>] sysctl_check_table+0x189/0x566
[ 3256.534257]
[<ffffffff80248abf>] __register_sysctl_paths+0xee/0x29e
[ 3256.534257]
[<ffffffff80248c98>] register_sysctl_paths+0x29/0x2b
[ 3256.534257]
[<ffffffff80248cad>] register_sysctl_table+0x13/0x15
[ 3256.534257]
[<ffffffff8023758b>] register_sched_domain_sysctl+0x42a/0x440
[ 3256.534257]
[<ffffffff8069878f>] sched_init_smp+0x12e/0x242
[ 3256.534257]
[<ffffffff80684631>] kernel_init+0x111/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80248d45>] __sysctl_head_next+0x1f/0xd3
[ 3256.534257]
[<ffffffff8025cfb6>] sysctl_check_lookup+0xcd/0xf5
[ 3256.534257]
[<ffffffff8025d1ba>] sysctl_check_table+0x189/0x566
[ 3256.534257]
[<ffffffff80248abf>] __register_sysctl_paths+0xee/0x29e
[ 3256.534257]
[<ffffffff80248c98>] register_sysctl_paths+0x29/0x2b
[ 3256.534257]
[<ffffffff80248cad>] register_sysctl_table+0x13/0x15
[ 3256.534257]
[<ffffffff8023758b>] register_sched_domain_sysctl+0x42a/0x440
[ 3256.534257]
[<ffffffff8069878f>] sched_init_smp+0x12e/0x242
[ 3256.534257]
[<ffffffff80684631>] kernel_init+0x111/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802488b1>] sysctl_head_put+0x18/0x3d
[ 3256.534257]
[<ffffffff8030dd80>] proc_delete_inode+0x3f/0x4c
[ 3256.534257]
[<ffffffff802dbe0e>] generic_delete_inode+0xe0/0x173
[ 3256.534257]
[<ffffffff802daf42>] iput+0x61/0x65
[ 3256.534257]
[<ffffffff802d81b2>] dentry_iput+0xa9/0xc1
[ 3256.534257]
[<ffffffff802d82af>] d_kill+0x40/0x60
[ 3256.534257]
[<ffffffff802d8574>] __shrink_dcache_sb+0x2a5/0x33d
[ 3256.534257]
[<ffffffff802d86fd>] shrink_dcache_memory+0xf1/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0d4f>] try_to_free_pages+0x26c/0x36a
[ 3256.534257]
[<ffffffff80299f7a>] __alloc_pages_internal+0x2a3/0x459
[ 3256.534257]
[<ffffffff802be38f>] alloc_page_vma+0x17b/0x198
[ 3256.534257]
[<ffffffff802a98cc>] handle_mm_fault+0x24a/0x709
[ 3256.534257]
[<ffffffff80227fd3>] do_page_fault+0x207/0x21e
[ 3256.534257]
[<ffffffff8048d055>] page_fault+0x25/0x30
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80248d45>] __sysctl_head_next+0x1f/0xd3
[ 3256.534257]
[<ffffffff8025cfb6>] sysctl_check_lookup+0xcd/0xf5
[ 3256.534257]
[<ffffffff8025d1ba>] sysctl_check_table+0x189/0x566
[ 3256.534257]
[<ffffffff80248abf>] __register_sysctl_paths+0xee/0x29e
[ 3256.534257]
[<ffffffff80248c98>] register_sysctl_paths+0x29/0x2b
[ 3256.534257]
[<ffffffff80248cad>] register_sysctl_table+0x13/0x15
[ 3256.534257]
[<ffffffff8023758b>] register_sched_domain_sysctl+0x42a/0x440
[ 3256.534257]
[<ffffffff8069878f>] sched_init_smp+0x12e/0x242
[ 3256.534257]
[<ffffffff80684631>] kernel_init+0x111/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       }
[ 3256.534257]       ... key      at: [<ffffffff80607f98>]
sysctl_lock+0x18/0x40 [ 3256.534257]      ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff802487ac>] sysctl_is_seen+0x23/0x58
[ 3256.534257]    [<ffffffff80314f49>] proc_sys_compare+0x37/0x4a
[ 3256.534257]    [<ffffffff802d9a58>] __d_lookup+0xf2/0x195
[ 3256.534257]    [<ffffffff802d0fc6>] __lookup_hash+0x52/0x126
[ 3256.534257]    [<ffffffff802d10cf>] lookup_hash+0x35/0x40
[ 3256.534257]    [<ffffffff802d43e3>] do_filp_open+0x17b/0x842
[ 3256.534257]    [<ffffffff802c72c2>] do_sys_open+0x53/0xda
[ 3256.534257]    [<ffffffff802c7372>] sys_open+0x1b/0x1d
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]      -> (&dentry->d_lock/1){+.+...} ops:
309 { [ 3256.534257]         HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c650>] _spin_lock_nested+0x3f/0x73
[ 3256.534257]
[<ffffffff802d950f>] d_move_locked+0x6d/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c650>] _spin_lock_nested+0x3f/0x73
[ 3256.534257]
[<ffffffff802d950f>] d_move_locked+0x6d/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c650>] _spin_lock_nested+0x3f/0x73
[ 3256.534257]
[<ffffffff802d950f>] d_move_locked+0x6d/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       }
[ 3256.534257]       ... key      at: [<ffffffff8116ce81>]
__key.28008+0x1/0x10 [ 3256.534257]      ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c650>] _spin_lock_nested+0x3f/0x73
[ 3256.534257]    [<ffffffff802d950f>] d_move_locked+0x6d/0x25c
[ 3256.534257]    [<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]    [<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]    [<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]    [<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802f2c0a>] inotify_d_instantiate+0x1b/0x49 [ 3256.534257]
[<ffffffff802d912a>] __d_instantiate+0x37/0x39 [ 3256.534257]
[<ffffffff802d9164>] d_instantiate+0x38/0x49 [ 3256.534257]
[<ffffffff802d9fb0>] d_alloc_root+0x45/0x4d [ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba [ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2 [ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18 [ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99 [ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16 [ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8 [ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271 [ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e [ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398 [ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]    [<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     -> (vfsmount_lock){+.+...} ops:
154348 { [ 3256.534257]        HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802dfce2>] alloc_vfsmnt+0x4f/0x14c
[ 3256.534257]
[<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802dfce2>] alloc_vfsmnt+0x4f/0x14c
[ 3256.534257]
[<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802dfce2>] alloc_vfsmnt+0x4f/0x14c
[ 3256.534257]
[<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff80676458>]
vfsmount_lock+0x18/0x40 [ 3256.534257]      ->
(mnt_id_ida.lock){......} ops: 98 { [ 3256.534257]         INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]
[<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]
[<ffffffff802dfcd6>] alloc_vfsmnt+0x43/0x14c
[ 3256.534257]
[<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       }
[ 3256.534257]       ... key      at: [<ffffffff80613850>]
mnt_id_ida+0x30/0x60 [ 3256.534257]      ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80355029>] get_from_free_list+0x1c/0x50
[ 3256.534257]    [<ffffffff803550f2>] idr_get_empty_slot+0x2f/0x24d
[ 3256.534257]    [<ffffffff80355353>] ida_get_new_above+0x43/0x1b4
[ 3256.534257]    [<ffffffff803554d2>] ida_get_new+0xe/0x10
[ 3256.534257]    [<ffffffff802dfcf1>] alloc_vfsmnt+0x5e/0x14c
[ 3256.534257]    [<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]    [<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]    [<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]    [<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]    [<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]    [<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]      -> (&q->lock){-.-.-.} ops: 14667692
{ [ 3256.534257]         IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff8025651f>] prepare_to_wait+0x1e/0x69
[ 3256.534257]
[<ffffffff802a0179>] kswapd+0xf2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c
[ 3256.534257]
[<ffffffff80488c36>] wait_for_common+0x37/0x142
[ 3256.534257]
[<ffffffff80488dcb>] wait_for_completion+0x18/0x1a
[ 3256.534257]
[<ffffffff802561b9>] kthread_create+0xac/0x143
[ 3256.534257]
[<ffffffff8048616b>] migration_call+0x47/0x4cc
[ 3256.534257]
[<ffffffff806980b0>] migration_init+0x22/0x58
[ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185
[ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       }
[ 3256.534257]       ... key      at: [<ffffffff809f2a68>]
__key.19384+0x0/0x8 [ 3256.534257]       -> (&rq->lock){-.-.-.} ops:
4747559 { [ 3256.534257]          IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80231c89>] task_rq_lock+0x4c/0x7e
[ 3256.534257]
[<ffffffff80239d54>] set_cpus_allowed_ptr+0x1f/0x118
[ 3256.534257]
[<ffffffff802a0102>] kswapd+0x7b/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]          INITIAL
USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff802368eb>] rq_attach_root+0x16/0xcb
[ 3256.534257]
[<ffffffff806984d9>] sched_init+0x3f3/0x57b
[ 3256.534257]
[<ffffffff80684a34>] start_kernel+0x147/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        }
[ 3256.534257]        ... key      at: [<ffffffff808ed4b0>]
__key.47760+0x0/0x8 [ 3256.534257]        -> (&vec->lock){..-...} ops:
2840 { [ 3256.534257]           IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80292234>] cpupri_set+0xce/0x130
[ 3256.534257]
[<ffffffff80234452>] rq_online_rt+0x6a/0x6f
[ 3256.534257]
[<ffffffff80230ebb>] set_rq_online+0x48/0x55
[ 3256.534257]
[<ffffffff80236976>] rq_attach_root+0xa1/0xcb
[ 3256.534257]
[<ffffffff806984d9>] sched_init+0x3f3/0x57b
[ 3256.534257]
[<ffffffff80684a34>] start_kernel+0x147/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         }
[ 3256.534257]         ... key      at: [<ffffffff811690a8>]
__key.16190+0x0/0x18 [ 3256.534257]        ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80292234>] cpupri_set+0xce/0x130
[ 3256.534257]    [<ffffffff80234452>] rq_online_rt+0x6a/0x6f
[ 3256.534257]    [<ffffffff80230ebb>] set_rq_online+0x48/0x55
[ 3256.534257]    [<ffffffff80236976>] rq_attach_root+0xa1/0xcb
[ 3256.534257]    [<ffffffff806984d9>] sched_init+0x3f3/0x57b
[ 3256.534257]    [<ffffffff80684a34>] start_kernel+0x147/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]        -> (&rt_b->rt_runtime_lock){..-...} ops: 125
{ [ 3256.534257]           IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80234ba2>] enqueue_task_rt+0x1a6/0x266
[ 3256.534257]
[<ffffffff80230806>] enqueue_task+0x5b/0x66
[ 3256.534257]
[<ffffffff80230916>] activate_task+0x28/0x31
[ 3256.534257]
[<ffffffff80239bdf>] try_to_wake_up+0x1df/0x307
[ 3256.534257]
[<ffffffff80239d33>] wake_up_process+0x10/0x12
[ 3256.534257]
[<ffffffff804861fb>] migration_call+0xd7/0x4cc
[ 3256.534257]
[<ffffffff806980d2>] migration_init+0x44/0x58
[ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185
[ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         }
[ 3256.534257]         ... key      at: [<ffffffff808ed4b8>]
__key.38426+0x0/0x8 [ 3256.534257]         -> (&cpu_base->lock){-.-.-.}
ops: 5183672 { [ 3256.534257]            IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80259021>] lock_hrtimer_base+0x25/0x4b
[ 3256.534257]
[<ffffffff8025919e>] __hrtimer_start_range_ns+0x2c/0x22f
[ 3256.534257]
[<ffffffff80234bee>] enqueue_task_rt+0x1f2/0x266
[ 3256.534257]
[<ffffffff80230806>] enqueue_task+0x5b/0x66
[ 3256.534257]
[<ffffffff80230916>] activate_task+0x28/0x31
[ 3256.534257]
[<ffffffff80239bdf>] try_to_wake_up+0x1df/0x307
[ 3256.534257]
[<ffffffff80239d33>] wake_up_process+0x10/0x12
[ 3256.534257]
[<ffffffff804861fb>] migration_call+0xd7/0x4cc
[ 3256.534257]
[<ffffffff806980d2>] migration_init+0x44/0x58
[ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185
[ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]          }
[ 3256.534257]          ... key      at: [<ffffffff809f2aa0>]
__key.21390+0x0/0x8 [ 3256.534257]         ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80259021>] lock_hrtimer_base+0x25/0x4b
[ 3256.534257]    [<ffffffff8025919e>]
__hrtimer_start_range_ns+0x2c/0x22f [ 3256.534257]
[<ffffffff80234bee>] enqueue_task_rt+0x1f2/0x266 [ 3256.534257]
[<ffffffff80230806>] enqueue_task+0x5b/0x66 [ 3256.534257]
[<ffffffff80230916>] activate_task+0x28/0x31 [ 3256.534257]
[<ffffffff80239bdf>] try_to_wake_up+0x1df/0x307 [ 3256.534257]
[<ffffffff80239d33>] wake_up_process+0x10/0x12 [ 3256.534257]
[<ffffffff804861fb>] migration_call+0xd7/0x4cc [ 3256.534257]
[<ffffffff806980d2>] migration_init+0x44/0x58 [ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185 [ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]         -> (&rt_rq->rt_runtime_lock){-.....} ops: 1621
{ [ 3256.534257]            IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802322fb>] update_curr_rt+0xbf/0x14e
[ 3256.534257]
[<ffffffff8023463c>] dequeue_task_rt+0x1f/0x7a
[ 3256.534257]
[<ffffffff802308e2>] dequeue_task+0xd1/0xdd
[ 3256.534257]
[<ffffffff80230947>] deactivate_task+0x28/0x31
[ 3256.534257]
[<ffffffff80488fab>] __schedule+0x1de/0xa17
[ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31
[ 3256.534257]
[<ffffffff8023e1a4>] migration_thread+0x1bb/0x267
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]          }
[ 3256.534257]          ... key      at: [<ffffffff808ed4c0>]
__key.47715+0x0/0x8 [ 3256.534257]         ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff8023263e>] __enable_runtime+0x38/0x78
[ 3256.534257]    [<ffffffff80234436>] rq_online_rt+0x4e/0x6f
[ 3256.534257]    [<ffffffff80230ebb>] set_rq_online+0x48/0x55
[ 3256.534257]    [<ffffffff80486238>] migration_call+0x114/0x4cc
[ 3256.534257]    [<ffffffff8025a197>] notifier_call_chain+0x33/0x5b
[ 3256.534257]    [<ffffffff8025a22f>] raw_notifier_call_chain+0xf/0x11
[ 3256.534257]    [<ffffffff80486a21>] _cpu_up+0xe0/0x12f
[ 3256.534257]    [<ffffffff80486ad3>] cpu_up+0x63/0x78
[ 3256.534257]    [<ffffffff806845dd>] kernel_init+0xbd/0x189
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]        ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80234ba2>] enqueue_task_rt+0x1a6/0x266 [ 3256.534257]
[<ffffffff80230806>] enqueue_task+0x5b/0x66 [ 3256.534257]
[<ffffffff80230916>] activate_task+0x28/0x31 [ 3256.534257]
[<ffffffff80239bdf>] try_to_wake_up+0x1df/0x307 [ 3256.534257]
[<ffffffff80239d33>] wake_up_process+0x10/0x12 [ 3256.534257]
[<ffffffff804861fb>] migration_call+0xd7/0x4cc [ 3256.534257]
[<ffffffff806980d2>] migration_init+0x44/0x58 [ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185 [ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]        ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802322fb>] update_curr_rt+0xbf/0x14e [ 3256.534257]
[<ffffffff8023463c>] dequeue_task_rt+0x1f/0x7a [ 3256.534257]
[<ffffffff802308e2>] dequeue_task+0xd1/0xdd [ 3256.534257]
[<ffffffff80230947>] deactivate_task+0x28/0x31 [ 3256.534257]
[<ffffffff80488fab>] __schedule+0x1de/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff8023e1a4>] migration_thread+0x1bb/0x267 [ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]        -> (&rq->lock/1){..-...} ops: 8988
{ [ 3256.534257]           IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         }
[ 3256.534257]         ... key      at: [<ffffffff808ed4b1>]
__key.47760+0x1/0x8 [ 3256.534257]         ->
(&sig->cputimer.lock){-.-...} ops: 8005 { [ 3256.534257]
IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff8025721f>] thread_group_cputimer+0x2d/0xb6
[ 3256.534257]
[<ffffffff80258543>] posix_cpu_timers_exit_group+0x15/0x3b
[ 3256.534257]
[<ffffffff80243785>] release_task+0xd6/0x367
[ 3256.534257]
[<ffffffff80243eec>] wait_consider_task+0x4d6/0x8b6
[ 3256.534257]
[<ffffffff8024445c>] do_wait+0x190/0x3b6
[ 3256.534257]
[<ffffffff80244707>] sys_wait4+0x85/0x9f
[ 3256.534257]
[<ffffffff80251ad6>] wait_for_helper+0x42/0x6e
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]          }
[ 3256.534257]          ... key      at: [<ffffffff808ef650>]
__key.17080+0x0/0x8 [ 3256.534257]         ... acquired at:
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]        ... acquired at: [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]        ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80231dab>] update_curr+0xf0/0x109 [ 3256.534257]
[<ffffffff80232add>] dequeue_entity+0x1b/0x1e5 [ 3256.534257]
[<ffffffff80232ff8>] dequeue_task_fair+0x29/0x75 [ 3256.534257]
[<ffffffff802308e2>] dequeue_task+0xd1/0xdd [ 3256.534257]
[<ffffffff80230947>] deactivate_task+0x28/0x31 [ 3256.534257]
[<ffffffff80488fab>] __schedule+0x1de/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80244e5e>] do_exit+0x698/0x6a6 [ 3256.534257]
[<ffffffff80244eeb>] do_group_exit+0x7f/0xaf [ 3256.534257]
[<ffffffff80244f2d>] sys_exit_group+0x12/0x16 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]       ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80231c89>] task_rq_lock+0x4c/0x7e [ 3256.534257]
[<ffffffff80239a94>] try_to_wake_up+0x94/0x307 [ 3256.534257]
[<ffffffff80239d14>] default_wake_function+0xd/0xf [ 3256.534257]
[<ffffffff80230a7e>] __wake_up_common+0x46/0x76 [ 3256.534257]
[<ffffffff80231ad5>] complete+0x38/0x4c [ 3256.534257]
[<ffffffff80255e9a>] kthreadd+0xfe/0x12f [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]       -> (&ep->lock){......} ops: 20927
{ [ 3256.534257]          INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff802f546c>] sys_epoll_ctl+0x29e/0x4ac
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        }
[ 3256.534257]        ... key      at: [<ffffffff8116d2c0>]
__key.24119+0x0/0x10 [ 3256.534257]        ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff80231c89>] task_rq_lock+0x4c/0x7e
[ 3256.534257]    [<ffffffff80239a94>] try_to_wake_up+0x94/0x307
[ 3256.534257]    [<ffffffff80239d14>] default_wake_function+0xd/0xf
[ 3256.534257]    [<ffffffff80230a7e>] __wake_up_common+0x46/0x76
[ 3256.534257]    [<ffffffff80230ac1>] __wake_up_locked+0x13/0x15
[ 3256.534257]    [<ffffffff802f4dad>] ep_poll_callback+0xb4/0xf7
[ 3256.534257]    [<ffffffff80230a7e>] __wake_up_common+0x46/0x76
[ 3256.534257]    [<ffffffff80231b89>] __wake_up+0x38/0x50
[ 3256.534257]    [<ffffffff803afdc4>] n_tty_receive_buf+0xe6e/0xec2
[ 3256.534257]    [<ffffffff803b2851>] pty_write+0x39/0x43
[ 3256.534257]    [<ffffffff803ae3c9>] n_tty_write+0x260/0x38c
[ 3256.534257]    [<ffffffff803abcc5>] tty_write+0x18c/0x226
[ 3256.534257]    [<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]    [<ffffffff803abdc0>] redirected_tty_write+0x61/0x92
[ 3256.534257]    [<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]    [<ffffffff802c953d>] sys_write+0x47/0x6e
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]       ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff802f4d17>] ep_poll_callback+0x1e/0xf7 [ 3256.534257]
[<ffffffff80230a7e>] __wake_up_common+0x46/0x76 [ 3256.534257]
[<ffffffff80231b89>] __wake_up+0x38/0x50 [ 3256.534257]
[<ffffffff803afdc4>] n_tty_receive_buf+0xe6e/0xec2 [ 3256.534257]
[<ffffffff803b2851>] pty_write+0x39/0x43 [ 3256.534257]
[<ffffffff803ae3c9>] n_tty_write+0x260/0x38c [ 3256.534257]
[<ffffffff803abcc5>] tty_write+0x18c/0x226 [ 3256.534257]
[<ffffffff802c93f0>] vfs_write+0xae/0x137 [ 3256.534257]
[<ffffffff803abdc0>] redirected_tty_write+0x61/0x92 [ 3256.534257]
[<ffffffff802c93f0>] vfs_write+0xae/0x137 [ 3256.534257]
[<ffffffff802c953d>] sys_write+0x47/0x6e [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]      ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff80231b73>] __wake_up+0x22/0x50 [ 3256.534257]
[<ffffffff802de6b6>] touch_mnt_namespace+0x2f/0x31 [ 3256.534257]
[<ffffffff802deb45>] commit_tree+0xdf/0xe1 [ 3256.534257]
[<ffffffff802df810>] attach_recursive_mnt+0x176/0x21d [ 3256.534257]
[<ffffffff802df95b>] graft_tree+0xa4/0xcc [ 3256.534257]
[<ffffffff802dfa31>] do_add_mount+0xae/0x117 [ 3256.534257]
[<ffffffff802e0ba3>] do_mount+0x706/0x735 [ 3256.534257]
[<ffffffff802e0c5b>] sys_mount+0x89/0xd6 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802d8c33>] __d_path+0x3d/0x15e [ 3256.534257]
[<ffffffff802d8fa4>] d_path+0xc7/0xee [ 3256.534257]
[<ffffffff8030fa59>] proc_pid_readlink+0x6e/0xc7 [ 3256.534257]
[<ffffffff802cc40b>] sys_readlinkat+0x6b/0x84 [ 3256.534257]
[<ffffffff802cc43a>] sys_readlink+0x16/0x18 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     -> (rename_lock){+.+...} ops: 217
{ [ 3256.534257]        HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d94d4>] d_move_locked+0x32/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d94d4>] d_move_locked+0x32/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d94d4>] d_move_locked+0x32/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff806763e0>]
rename_lock+0x20/0x80 [ 3256.534257]      ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff802d94f0>] d_move_locked+0x4e/0x25c
[ 3256.534257]    [<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]    [<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]    [<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]    [<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]      ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80268a22>] lock_release_non_nested+0x1bd/0x222
[ 3256.534257]    [<ffffffff80268c87>] lock_release+0x200/0x236
[ 3256.534257]    [<ffffffff8048c4df>] _spin_unlock+0x1e/0x4b
[ 3256.534257]    [<ffffffff802d96d2>] d_move_locked+0x230/0x25c
[ 3256.534257]    [<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]    [<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]    [<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]    [<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802d94d4>] d_move_locked+0x32/0x25c [ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35 [ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8 [ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a [ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     -> (sb_lock){+.+.-.} ops: 6053
{ [ 3256.534257]        HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802caa0a>] sget+0x46/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802caa0a>] sget+0x46/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d8671>] shrink_dcache_memory+0x65/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802caa0a>] sget+0x46/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff806124f8>]
sb_lock+0x18/0x40 [ 3256.534257]      -> (unnamed_dev_ida.lock){......}
ops: 52 { [ 3256.534257]         INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]
[<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]
[<ffffffff802ca331>] set_anon_super+0x25/0xc1
[ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       }
[ 3256.534257]       ... key      at: [<ffffffff80612590>]
unnamed_dev_ida+0x30/0x60 [ 3256.534257]      ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]    [<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]    [<ffffffff802ca331>] set_anon_super+0x25/0xc1
[ 3256.534257]    [<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]    [<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]    [<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]    [<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]    [<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]    [<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]    [<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]    [<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]    [<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]      ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c [ 3256.534257]
[<ffffffff80355941>] idr_pre_get+0x2d/0x75 [ 3256.534257]
[<ffffffff803559a5>] ida_pre_get+0x1c/0xf7 [ 3256.534257]
[<ffffffff802ca331>] set_anon_super+0x25/0xc1 [ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0 [ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2 [ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18 [ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99 [ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16 [ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8 [ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271 [ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e [ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398 [ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]    [<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]      ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c20c5>] kmem_cache_alloc_node+0x112/0x214
[ 3256.534257]    [<ffffffff802c22ce>] cache_grow+0x107/0x3dc
[ 3256.534257]    [<ffffffff802c2859>] cache_alloc_refill+0x2b6/0x305
[ 3256.534257]    [<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c
[ 3256.534257]    [<ffffffff80355941>] idr_pre_get+0x2d/0x75
[ 3256.534257]    [<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]    [<ffffffff802ca331>] set_anon_super+0x25/0xc1
[ 3256.534257]    [<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]    [<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]    [<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]    [<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]    [<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]    [<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]    [<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]    [<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]    [<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]      -> (unnamed_dev_lock){+.+...} ops: 18
{ [ 3256.534257]         HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802ca34b>] set_anon_super+0x3f/0xc1
[ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802ca34b>] set_anon_super+0x3f/0xc1
[ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802ca34b>] set_anon_super+0x3f/0xc1
[ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       }
[ 3256.534257]       ... key      at: [<ffffffff80612538>]
unnamed_dev_lock+0x18/0x40 [ 3256.534257]       ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80355029>] get_from_free_list+0x1c/0x50
[ 3256.534257]    [<ffffffff803550f2>] idr_get_empty_slot+0x2f/0x24d
[ 3256.534257]    [<ffffffff80355353>] ida_get_new_above+0x43/0x1b4
[ 3256.534257]    [<ffffffff803554d2>] ida_get_new+0xe/0x10
[ 3256.534257]    [<ffffffff802ca35a>] set_anon_super+0x4e/0xc1
[ 3256.534257]    [<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]    [<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]    [<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]    [<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]    [<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]    [<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]    [<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]    [<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]    [<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]      ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802ca34b>] set_anon_super+0x3f/0xc1 [ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0 [ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2 [ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18 [ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99 [ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16 [ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8 [ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271 [ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e [ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398 [ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]    [<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802d8671>] shrink_dcache_memory+0x65/0x193 [ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188 [ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8 [ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     -> (&sem->wait_lock){....-.} ops: 3141613
{ [ 3256.534257]        IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80359678>] __down_read_trylock+0x16/0x46
[ 3256.534257]
[<ffffffff802599a8>] down_read_trylock+0x13/0x4c
[ 3256.534257]
[<ffffffff802d86c5>] shrink_dcache_memory+0xb9/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80359632>] __down_write_trylock+0x16/0x46
[ 3256.534257]
[<ffffffff802598c1>] down_write_nested+0x4e/0x7a
[ 3256.534257]
[<ffffffff802cacf5>] sget+0x331/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff8116ff98>]
__key.16979+0x0/0x8 [ 3256.534257]      ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff80231c89>] task_rq_lock+0x4c/0x7e
[ 3256.534257]    [<ffffffff80239a94>] try_to_wake_up+0x94/0x307
[ 3256.534257]    [<ffffffff80239d33>] wake_up_process+0x10/0x12
[ 3256.534257]    [<ffffffff8035984d>] __up_write+0xdb/0x124
[ 3256.534257]    [<ffffffff80259a3c>] up_write+0x26/0x2a
[ 3256.534257]    [<ffffffff8020fee0>] sys_mmap+0xae/0xce
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff80359678>] __down_read_trylock+0x16/0x46 [ 3256.534257]
[<ffffffff802599a8>] down_read_trylock+0x13/0x4c [ 3256.534257]
[<ffffffff802d86c5>] shrink_dcache_memory+0xb9/0x193 [ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188 [ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8 [ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802f2efd>] set_dentry_child_flags+0x27/0xdf [ 3256.534257]
[<ffffffff802f30a5>] inotify_add_watch+0xf0/0x111 [ 3256.534257]
[<ffffffff802f3ff2>] sys_inotify_add_watch+0x120/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80297678>] rmqueue_bulk+0x30/0x96 [ 3256.534257]
[<ffffffff8029966e>] get_page_from_freelist+0x343/0x72e
[ 3256.534257]    [<ffffffff80299dd8>]
__alloc_pages_internal+0x101/0x459 [ 3256.534257]
[<ffffffff802c0b07>] kmem_getpages+0x68/0x12e [ 3256.534257]
[<ffffffff802c229d>] cache_grow+0xd6/0x3dc [ 3256.534257]
[<ffffffff802c2859>] cache_alloc_refill+0x2b6/0x305 [ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c [ 3256.534257]
[<ffffffff80355941>] idr_pre_get+0x2d/0x75 [ 3256.534257]
[<ffffffff802f2dca>] inotify_handle_get_wd+0x24/0x65 [ 3256.534257]
[<ffffffff802f3014>] inotify_add_watch+0x5f/0x111 [ 3256.534257]
[<ffffffff802f3ff2>] sys_inotify_add_watch+0x120/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802f2cda>] pin_to_kill+0x36/0x102 [ 3256.534257]
[<ffffffff802f378b>] inotify_destroy+0x76/0xec [ 3256.534257]
[<ffffffff802f3b0c>] inotify_release+0x24/0xe8 [ 3256.534257]
[<ffffffff802c9e01>] __fput+0xeb/0x1a7 [ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802431a5>] put_files_struct+0x6b/0xc2 [ 3256.534257]
[<ffffffff80243243>] exit_files+0x47/0x50 [ 3256.534257]
[<ffffffff802449c5>] do_exit+0x1ff/0x6a6 [ 3256.534257]
[<ffffffff80244eeb>] do_group_exit+0x7f/0xaf [ 3256.534257]
[<ffffffff80244f2d>] sys_exit_group+0x12/0x16 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    -> (&dev->ev_mutex){+.+.+.} ops: 221537
{ [ 3256.534257]       HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f3ac0>] inotify_poll+0x3c/0x64
[ 3256.534257]
[<ffffffff802d731a>] do_select+0x3e9/0x5da
[ 3256.534257]
[<ffffffff802d7721>] core_sys_select+0x216/0x2e0
[ 3256.534257]
[<ffffffff802d7a21>] sys_select+0x94/0xbc
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f3ac0>] inotify_poll+0x3c/0x64
[ 3256.534257]
[<ffffffff802d731a>] do_select+0x3e9/0x5da
[ 3256.534257]
[<ffffffff802d7721>] core_sys_select+0x216/0x2e0
[ 3256.534257]
[<ffffffff802d7a21>] sys_select+0x94/0xbc
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
RECLAIM_FS-ON-W at:
[ 3256.534257]
[<ffffffff80265707>] mark_held_locks+0x4d/0x6b
[ 3256.534257]
[<ffffffff802657de>] lockdep_trace_alloc+0xb9/0xdb
[ 3256.534257]
[<ffffffff802c35db>] __kmalloc+0x70/0x27c
[ 3256.534257]
[<ffffffff802f43e2>] kernel_event+0xa7/0x10e
[ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]
[<ffffffff802f334a>] inotify_inode_queue_event+0xab/0xe0
[ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]
[<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a
[ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72
[ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f3ac0>] inotify_poll+0x3c/0x64
[ 3256.534257]
[<ffffffff802d731a>] do_select+0x3e9/0x5da
[ 3256.534257]
[<ffffffff802d7721>] core_sys_select+0x216/0x2e0
[ 3256.534257]
[<ffffffff802d7a21>] sys_select+0x94/0xbc
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff8116d298>]
__key.21429+0x0/0x8 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff802c262c>] cache_alloc_refill+0x89/0x305
[ 3256.534257]    [<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c
[ 3256.534257]    [<ffffffff802f4368>] kernel_event+0x2d/0x10e
[ 3256.534257]    [<ffffffff802f4520>]
inotify_dev_queue_event+0xd7/0x157 [ 3256.534257]
[<ffffffff802f334a>] inotify_inode_queue_event+0xab/0xe0
[ 3256.534257]    [<ffffffff802f3a2b>]
inotify_dentry_parent_queue_event+0x71/0x92 [ 3256.534257]
[<ffffffff802c9d90>] __fput+0x7a/0x1a7 [ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff80231b73>] __wake_up+0x22/0x50 [ 3256.534257]
[<ffffffff802f4571>] inotify_dev_queue_event+0x128/0x157
[ 3256.534257]    [<ffffffff802f334a>]
inotify_inode_queue_event+0xab/0xe0 [ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]    [<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]    [<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c [ 3256.534257]
[<ffffffff80488f28>] __schedule+0x15b/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80489a39>] preempt_schedule+0x31/0x4f [ 3256.534257]
[<ffffffff8048a8a4>] mutex_lock_nested+0x353/0x362 [ 3256.534257]
[<ffffffff802f3ac0>] inotify_poll+0x3c/0x64 [ 3256.534257]
[<ffffffff802d6b3e>] do_sys_poll+0x220/0x3c7 [ 3256.534257]
[<ffffffff802d6e7a>] sys_poll+0x50/0xba [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c36f3>] __kmalloc+0x188/0x27c [ 3256.534257]
[<ffffffff802f43e2>] kernel_event+0xa7/0x10e [ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]    [<ffffffff802f334a>]
inotify_inode_queue_event+0xab/0xe0 [ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]    [<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]    [<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80297678>] rmqueue_bulk+0x30/0x96 [ 3256.534257]
[<ffffffff8029966e>] get_page_from_freelist+0x343/0x72e
[ 3256.534257]    [<ffffffff80299dd8>]
__alloc_pages_internal+0x101/0x459 [ 3256.534257]
[<ffffffff802c0b07>] kmem_getpages+0x68/0x12e [ 3256.534257]
[<ffffffff802c229d>] cache_grow+0xd6/0x3dc [ 3256.534257]
[<ffffffff802c2859>] cache_alloc_refill+0x2b6/0x305 [ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c [ 3256.534257]
[<ffffffff802f4368>] kernel_event+0x2d/0x10e [ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]    [<ffffffff802f334a>]
inotify_inode_queue_event+0xab/0xe0 [ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]    [<ffffffff802d9c78>] d_delete+0xc6/0xce
[ 3256.534257]    [<ffffffff802d1a68>] vfs_unlink+0xe7/0xfb
[ 3256.534257]    [<ffffffff802d3aa0>] do_unlinkat+0xcd/0x164
[ 3256.534257]    [<ffffffff802d3b48>] sys_unlink+0x11/0x13
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362 [ 3256.534257]
[<ffffffff802f447f>] inotify_dev_queue_event+0x36/0x157
[ 3256.534257]    [<ffffffff802f334a>]
inotify_inode_queue_event+0xab/0xe0 [ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]    [<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]    [<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c [ 3256.534257]
[<ffffffff80488f28>] __schedule+0x15b/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80489a39>] preempt_schedule+0x31/0x4f [ 3256.534257]
[<ffffffff8048a8a4>] mutex_lock_nested+0x353/0x362 [ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]    [<ffffffff802f406f>]
sys_inotify_add_watch+0x19d/0x1a9 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362 [ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]    [<ffffffff802f406f>]
sys_inotify_add_watch+0x19d/0x1a9 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c [ 3256.534257]
[<ffffffff80488f28>] __schedule+0x15b/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80489a39>] preempt_schedule+0x31/0x4f [ 3256.534257]
[<ffffffff8048a8a4>] mutex_lock_nested+0x353/0x362 [ 3256.534257]
[<ffffffff802f32ee>] inotify_inode_queue_event+0x4f/0xe0
[ 3256.534257]    [<ffffffff802f3a2b>]
inotify_dentry_parent_queue_event+0x71/0x92 [ 3256.534257]
[<ffffffff802c9671>] vfs_read+0x10d/0x134 [ 3256.534257]
[<ffffffff802c975c>] sys_read+0x47/0x6f [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257] [ 3256.534257]
-> (pgd_lock){......} ops: 11776 { [ 3256.534257]      INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80228b66>] update_page_count+0x1b/0x37
[ 3256.534257]
[<ffffffff806b3720>] phys_pte_init+0x126/0x138
[ 3256.534257]
[<ffffffff806b38f8>] phys_pmd_init+0x1c6/0x26f
[ 3256.534257]
[<ffffffff806b3ab1>] phys_pud_init+0x110/0x2a9
[ 3256.534257]
[<ffffffff806951d3>] kernel_physical_mapping_init+0xc9/0x1ad
[ 3256.534257]
[<ffffffff8047851f>] init_memory_mapping+0x389/0x412
[ 3256.534257]
[<ffffffff8068713b>] setup_arch+0x475/0x688
[ 3256.534257]
[<ffffffff80684983>] start_kernel+0x96/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff80606ae8>]
pgd_lock+0x18/0x40 [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff8022b718>] pgd_free+0x1f/0x8f [ 3256.534257]
[<ffffffff8023f174>] __mmdrop+0x22/0x3e [ 3256.534257]
[<ffffffff802377de>] finish_task_switch+0xb3/0xdc [ 3256.534257]
[<ffffffff8048982d>] thread_return+0x49/0xb6 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80489a39>] preempt_schedule+0x31/0x4f [ 3256.534257]
[<ffffffff8048a8a4>] mutex_lock_nested+0x353/0x362 [ 3256.534257]
[<ffffffff802f32ee>] inotify_inode_queue_event+0x4f/0xe0
[ 3256.534257]    [<ffffffff802f3a2b>]
inotify_dentry_parent_queue_event+0x71/0x92 [ 3256.534257]
[<ffffffff802c9671>] vfs_read+0x10d/0x134 [ 3256.534257]
[<ffffffff802c975c>] sys_read+0x47/0x6f [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]  ... acquired at: [ 3256.534257]    [<ffffffff80267b13>]
__lock_acquire+0x13ed/0x177c [ 3256.534257]    [<ffffffff80267fa6>]
lock_acquire+0x104/0x130 [ 3256.534257]    [<ffffffff8048a5bb>]
mutex_lock_nested+0x6a/0x362 [ 3256.534257]    [<ffffffff802f38e5>]
inotify_unmount_inodes+0xbf/0x194 [ 3256.534257]
[<ffffffff802dbc47>] invalidate_inodes+0x50/0x137 [ 3256.534257]
[<ffffffff802edeaf>] __invalidate_device+0x30/0x4e [ 3256.534257]
[<ffffffff8034d652>] invalidate_partition+0x27/0x3d [ 3256.534257]
[<ffffffff80316b2b>] del_gendisk+0x6e/0x121 [ 3256.534257]
[<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod] [ 3256.534257]
[<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f [scsi_mod]
[ 3256.534257]    [<ffffffff803d2ce8>]
__device_release_driver+0x80/0xa5 [ 3256.534257]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b [ 3256.534257]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd [ 3256.534257]
[<ffffffff803d066e>] device_del+0x138/0x177 [ 3256.534257]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.534257]    [<ffffffffa009da02>] scsi_forget_host+0x42/0x6a
[scsi_mod] [ 3256.534257]    [<ffffffffa00978b3>]
scsi_remove_host+0x90/0x115 [scsi_mod] [ 3256.534257]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.534257]    [<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24
[usb_storage] [ 3256.534257]    [<ffffffffa000c030>]
usb_unbind_interface+0x63/0xf3 [usbcore] [ 3256.534257]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534257]    [<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534257]    [<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534257]    [<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534257]    [<ffffffffa00090c5>] usb_disable_device+0x106/0x182
[usbcore] [ 3256.534257]    [<ffffffffa00039f3>]
usb_disconnect+0xcf/0x148 [usbcore] [ 3256.534257]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534257]    [<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]  -> (&inode->i_data.tree_lock){..-.-.}
ops: 117446 { [ 3256.534257]     IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c
[ 3256.534257]
[<ffffffff8029e50d>] __remove_mapping+0x53/0xe6
[ 3256.534257]
[<ffffffff8029ed9b>] shrink_page_list+0x595/0x736
[ 3256.534257]
[<ffffffff8029f5a7>] shrink_list+0x2aa/0x62a
[ 3256.534257]
[<ffffffff8029fbab>] shrink_zone+0x284/0x32e
[ 3256.534257]
[<ffffffff802a0553>] kswapd+0x4cc/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c
[ 3256.534257]
[<ffffffff80293602>] add_to_page_cache_locked+0x6c/0xe0
[ 3256.534257]
[<ffffffff802936a2>] add_to_page_cache_lru+0x2c/0x5f
[ 3256.534257]
[<ffffffff8029374d>] grab_cache_page_write_begin+0x78/0xa2
[ 3256.534257]
[<ffffffff802e36ac>] simple_write_begin+0x29/0x57
[ 3256.534257]
[<ffffffff802940d3>] generic_file_buffered_write+0x139/0x2ff
[ 3256.534257]
[<ffffffff80294791>] __generic_file_aio_write_nolock+0x358/0x38c
[ 3256.534257]
[<ffffffff8029503d>] generic_file_aio_write+0x69/0xc5
[ 3256.534257]
[<ffffffff802c8a5e>] do_sync_write+0xe7/0x12d
[ 3256.534257]
[<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]
[<ffffffff802c953d>] sys_write+0x47/0x6e
[ 3256.534257]
[<ffffffff80685a84>] do_copy+0x2c/0xda
[ 3256.534257]
[<ffffffff806854e8>] flush_buffer+0x7c/0xa1
[ 3256.534257]
[<ffffffff806a2ece>] gunzip+0x3d4/0x470
[ 3256.534257]
[<ffffffff80685915>] unpack_to_rootfs+0x2d4/0x417
[ 3256.534257]
[<ffffffff8068634d>] populate_rootfs+0x63/0xd2
[ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185
[ 3256.534257]
[<ffffffff80684653>] kernel_init+0x133/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]   }
[ 3256.534257]   ... key      at: [<ffffffff8116ced8>]
__key.28883+0x0/0x8 [ 3256.534257]   -> (key#4){..-...} ops: 568
{ [ 3256.534257]      IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80362d72>] __percpu_counter_add+0x54/0xb4
[ 3256.534257]
[<ffffffff8029b76f>] account_page_dirtied+0x4c/0x5e
[ 3256.534257]
[<ffffffff802e92ef>] __set_page_dirty+0x5d/0xa6
[ 3256.534257]
[<ffffffff802e93c6>] mark_buffer_dirty+0x8e/0x92
[ 3256.534257]
[<ffffffff802e9440>] __block_commit_write+0x76/0xa6
[ 3256.534257]
[<ffffffff802e960c>] block_write_end+0x4c/0x58
[ 3256.534257]
[<ffffffffa007735e>] ext3_writeback_write_end+0x41/0xd5 [ext3]
[ 3256.534257]
[<ffffffff8029414c>] generic_file_buffered_write+0x1b2/0x2ff
[ 3256.534257]
[<ffffffff80294791>] __generic_file_aio_write_nolock+0x358/0x38c
[ 3256.534257]
[<ffffffff8029503d>] generic_file_aio_write+0x69/0xc5
[ 3256.534257]
[<ffffffffa0074924>] ext3_file_write+0x1e/0x9e [ext3]
[ 3256.534257]
[<ffffffff802c8a5e>] do_sync_write+0xe7/0x12d
[ 3256.534257]
[<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]
[<ffffffff802c953d>] sys_write+0x47/0x6e
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff811697f0>]
__key.25612+0x0/0x8 [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80362d72>] __percpu_counter_add+0x54/0xb4 [ 3256.534257]
[<ffffffff8029b76f>] account_page_dirtied+0x4c/0x5e [ 3256.534257]
[<ffffffff802e92ef>] __set_page_dirty+0x5d/0xa6 [ 3256.534257]
[<ffffffff802e93c6>] mark_buffer_dirty+0x8e/0x92 [ 3256.534257]
[<ffffffff802e9440>] __block_commit_write+0x76/0xa6 [ 3256.534257]
[<ffffffff802e960c>] block_write_end+0x4c/0x58 [ 3256.534257]
[<ffffffffa007735e>] ext3_writeback_write_end+0x41/0xd5 [ext3]
[ 3256.534257]    [<ffffffff8029414c>]
generic_file_buffered_write+0x1b2/0x2ff [ 3256.534257]
[<ffffffff80294791>] __generic_file_aio_write_nolock+0x358/0x38c
[ 3256.534257]    [<ffffffff8029503d>] generic_file_aio_write+0x69/0xc5
[ 3256.534257]    [<ffffffffa0074924>] ext3_file_write+0x1e/0x9e [ext3]
[ 3256.534257]    [<ffffffff802c8a5e>] do_sync_write+0xe7/0x12d
[ 3256.534257]    [<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]    [<ffffffff802c953d>] sys_write+0x47/0x6e
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]   -> (key#5){..-.-.} ops: 286
{ [ 3256.534257]      IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80362d72>] __percpu_counter_add+0x54/0xb4
[ 3256.534257]
[<ffffffff80357e5a>] __prop_inc_single+0x3e/0x51
[ 3256.534257]
[<ffffffff8029b6f5>] task_dirty_inc+0x33/0x61
[ 3256.534257]
[<ffffffff8029b77d>] account_page_dirtied+0x5a/0x5e
[ 3256.534257]
[<ffffffff802e92ef>] __set_page_dirty+0x5d/0xa6
[ 3256.534257]
[<ffffffff802e93c6>] mark_buffer_dirty+0x8e/0x92
[ 3256.534257]
[<ffffffff802e9440>] __block_commit_write+0x76/0xa6
[ 3256.534257]
[<ffffffff802e960c>] block_write_end+0x4c/0x58
[ 3256.534257]
[<ffffffffa007735e>] ext3_writeback_write_end+0x41/0xd5 [ext3]
[ 3256.534257]
[<ffffffff8029414c>] generic_file_buffered_write+0x1b2/0x2ff
[ 3256.534257]
[<ffffffff80294791>] __generic_file_aio_write_nolock+0x358/0x38c
[ 3256.534257]
[<ffffffff8029503d>] generic_file_aio_write+0x69/0xc5
[ 3256.534257]
[<ffffffffa0074924>] ext3_file_write+0x1e/0x9e [ext3]
[ 3256.534257]
[<ffffffff802c8a5e>] do_sync_write+0xe7/0x12d
[ 3256.534257]
[<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]
[<ffffffff802c953d>] sys_write+0x47/0x6e
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff8116ff80>]
__key.11005+0x0/0x8 [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80362d72>] __percpu_counter_add+0x54/0xb4 [ 3256.534257]
[<ffffffff80357e5a>] __prop_inc_single+0x3e/0x51 [ 3256.534257]
[<ffffffff8029b6f5>] task_dirty_inc+0x33/0x61 [ 3256.534257]
[<ffffffff8029b77d>] account_page_dirtied+0x5a/0x5e [ 3256.534257]
[<ffffffff802e92ef>] __set_page_dirty+0x5d/0xa6 [ 3256.534257]
[<ffffffff802e93c6>] mark_buffer_dirty+0x8e/0x92 [ 3256.534257]
[<ffffffff802e9440>] __block_commit_write+0x76/0xa6 [ 3256.534257]
[<ffffffff802e960c>] block_write_end+0x4c/0x58 [ 3256.534257]
[<ffffffffa007735e>] ext3_writeback_write_end+0x41/0xd5 [ext3]
[ 3256.534257]    [<ffffffff8029414c>]
generic_file_buffered_write+0x1b2/0x2ff [ 3256.534257]
[<ffffffff80294791>] __generic_file_aio_write_nolock+0x358/0x38c
[ 3256.534257]    [<ffffffff8029503d>] generic_file_aio_write+0x69/0xc5
[ 3256.534257]    [<ffffffffa0074924>] ext3_file_write+0x1e/0x9e [ext3]
[ 3256.534257]    [<ffffffff802c8a5e>] do_sync_write+0xe7/0x12d
[ 3256.534257]    [<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]    [<ffffffff802c953d>] sys_write+0x47/0x6e
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]   -> (key#6){..-...} ops: 141
{ [ 3256.534257]      IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80362d72>] __percpu_counter_add+0x54/0xb4
[ 3256.534257]
[<ffffffff8035809e>] __prop_inc_percpu_max+0x79/0xa1
[ 3256.534257]
[<ffffffff8029a537>] test_clear_page_writeback+0xd4/0x10c
[ 3256.534257]
[<ffffffff80293401>] end_page_writeback+0x24/0x48
[ 3256.534257]
[<ffffffff802eb4d3>] __block_write_full_page+0x215/0x2f1
[ 3256.534257]
[<ffffffff802eb68f>] block_write_full_page+0xe0/0xed
[ 3256.534257]
[<ffffffff802ee8e7>] blkdev_writepage+0x13/0x15
[ 3256.534257]
[<ffffffff8029a145>] __writepage+0x15/0x3b
[ 3256.534257]
[<ffffffff8029aa71>] write_cache_pages+0x25d/0x3a3
[ 3256.534257]
[<ffffffff8029abd9>] generic_writepages+0x22/0x28
[ 3256.534257]
[<ffffffff8029ac0a>] do_writepages+0x2b/0x3b
[ 3256.534257]
[<ffffffff802e3dfd>] __writeback_single_inode+0x1bf/0x3f2
[ 3256.534257]
[<ffffffff802e44e4>] generic_sync_sb_inodes+0x2a1/0x445
[ 3256.534257]
[<ffffffff802e4879>] writeback_inodes+0x9d/0xf5
[ 3256.534257]
[<ffffffff8029ad6a>] wb_kupdate+0xad/0x123
[ 3256.534257]
[<ffffffff8029bb57>] pdflush+0x14a/0x236
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff8116ff68>]
__key.11077+0x0/0x8 [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80362d72>] __percpu_counter_add+0x54/0xb4 [ 3256.534257]
[<ffffffff8035809e>] __prop_inc_percpu_max+0x79/0xa1 [ 3256.534257]
[<ffffffff8029a537>] test_clear_page_writeback+0xd4/0x10c
[ 3256.534257]    [<ffffffff80293401>] end_page_writeback+0x24/0x48
[ 3256.534257]    [<ffffffff802eb4d3>]
__block_write_full_page+0x215/0x2f1 [ 3256.534257]
[<ffffffff802eb68f>] block_write_full_page+0xe0/0xed [ 3256.534257]
[<ffffffff802ee8e7>] blkdev_writepage+0x13/0x15 [ 3256.534257]
[<ffffffff8029a145>] __writepage+0x15/0x3b [ 3256.534257]
[<ffffffff8029aa71>] write_cache_pages+0x25d/0x3a3 [ 3256.534257]
[<ffffffff8029abd9>] generic_writepages+0x22/0x28 [ 3256.534257]
[<ffffffff8029ac0a>] do_writepages+0x2b/0x3b [ 3256.534257]
[<ffffffff802e3dfd>] __writeback_single_inode+0x1bf/0x3f2
[ 3256.534257]    [<ffffffff802e44e4>]
generic_sync_sb_inodes+0x2a1/0x445 [ 3256.534257]
[<ffffffff802e4879>] writeback_inodes+0x9d/0xf5 [ 3256.534257]
[<ffffffff8029ad6a>] wb_kupdate+0xad/0x123 [ 3256.534257]
[<ffffffff8029bb57>] pdflush+0x14a/0x236 [ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]  ... acquired at: [ 3256.534257]    [<ffffffff80267b13>]
__lock_acquire+0x13ed/0x177c [ 3256.534257]    [<ffffffff80267fa6>]
lock_acquire+0x104/0x130 [ 3256.534257]    [<ffffffff8048c7b2>]
_spin_lock_irq+0x48/0x7c [ 3256.534257]    [<ffffffff8029518e>]
remove_from_page_cache+0x23/0x39 [ 3256.534257]    [<ffffffff8029d737>]
truncate_complete_page+0x4d/0x62 [ 3256.534257]    [<ffffffff8029d83b>]
truncate_inode_pages_range+0xef/0x39c [ 3256.534257]
[<ffffffff8029daf5>] truncate_inode_pages+0xd/0x10 [ 3256.534257]
[<ffffffff802db8e7>] dispose_list+0x53/0x10e [ 3256.534257]
[<ffffffff802dbd10>] invalidate_inodes+0x119/0x137 [ 3256.534257]
[<ffffffff802edeaf>] __invalidate_device+0x30/0x4e [ 3256.534257]
[<ffffffff8034d652>] invalidate_partition+0x27/0x3d [ 3256.534257]
[<ffffffff80316b2b>] del_gendisk+0x6e/0x121 [ 3256.534257]
[<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod] [ 3256.534257]
[<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f [scsi_mod]
[ 3256.534257]    [<ffffffff803d2ce8>]
__device_release_driver+0x80/0xa5 [ 3256.534257]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b [ 3256.534257]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd [ 3256.534257]
[<ffffffff803d066e>] device_del+0x138/0x177 [ 3256.534257]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.534257]    [<ffffffffa009da02>] scsi_forget_host+0x42/0x6a
[scsi_mod] [ 3256.534257]    [<ffffffffa00978b3>]
scsi_remove_host+0x90/0x115 [scsi_mod] [ 3256.534257]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.534257]    [<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24
[usb_storage] [ 3256.534257]    [<ffffffffa000c030>]
usb_unbind_interface+0x63/0xf3 [usbcore] [ 3256.534257]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534257]    [<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534257]    [<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534257]    [<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534257]    [<ffffffffa00090c5>] usb_disable_device+0x106/0x182
[usbcore] [ 3256.534257]    [<ffffffffa00039f3>]
usb_disconnect+0xcf/0x148 [usbcore] [ 3256.534257]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534257]    [<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]  -> (&zone->lru_lock){..-.-.} ops: 187469
{ [ 3256.534257]     IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c
[ 3256.534257]
[<ffffffff8029cb31>] ____pagevec_lru_add+0xa5/0x197
[ 3256.534257]
[<ffffffff8029cc60>] drain_cpu_pagevecs+0x3d/0xad
[ 3256.534257]
[<ffffffff8029cd30>] lru_add_drain+0x1a/0x3d
[ 3256.534257]
[<ffffffff8029ef7d>] shrink_active_list+0x41/0x3c1
[ 3256.534257]
[<ffffffff802a03ad>] kswapd+0x326/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c
[ 3256.534257]
[<ffffffff8029cb31>] ____pagevec_lru_add+0xa5/0x197
[ 3256.534257]
[<ffffffff8029cdeb>] __lru_cache_add+0x8d/0xb7
[ 3256.534257]
[<ffffffff802936bc>] add_to_page_cache_lru+0x46/0x5f
[ 3256.534257]
[<ffffffff8029374d>] grab_cache_page_write_begin+0x78/0xa2
[ 3256.534257]
[<ffffffff802e36ac>] simple_write_begin+0x29/0x57
[ 3256.534257]
[<ffffffff802940d3>] generic_file_buffered_write+0x139/0x2ff
[ 3256.534257]
[<ffffffff80294791>] __generic_file_aio_write_nolock+0x358/0x38c
[ 3256.534257]
[<ffffffff8029503d>] generic_file_aio_write+0x69/0xc5
[ 3256.534257]
[<ffffffff802c8a5e>] do_sync_write+0xe7/0x12d
[ 3256.534257]
[<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]
[<ffffffff802c953d>] sys_write+0x47/0x6e
[ 3256.534257]
[<ffffffff80685b06>] do_copy+0xae/0xda
[ 3256.534257]
[<ffffffff806854e8>] flush_buffer+0x7c/0xa1
[ 3256.534257]
[<ffffffff806a2ece>] gunzip+0x3d4/0x470
[ 3256.534257]
[<ffffffff80685915>] unpack_to_rootfs+0x2d4/0x417
[ 3256.534257]
[<ffffffff8068634d>] populate_rootfs+0x63/0xd2
[ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185
[ 3256.534257]
[<ffffffff80684653>] kernel_init+0x133/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]   }
[ 3256.534257]   ... key      at: [<ffffffff81169128>]
__key.31694+0x0/0x8 [ 3256.534257]  ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c [ 3256.534257]
[<ffffffff8029cb31>] ____pagevec_lru_add+0xa5/0x197 [ 3256.534257]
[<ffffffff8029cc60>] drain_cpu_pagevecs+0x3d/0xad [ 3256.534257]
[<ffffffff8029cd30>] lru_add_drain+0x1a/0x3d [ 3256.534257]
[<ffffffff8029ce76>] __pagevec_release+0x11/0x2d [ 3256.534257]
[<ffffffff8029d871>] truncate_inode_pages_range+0x125/0x39c
[ 3256.534257]    [<ffffffff8029daf5>] truncate_inode_pages+0xd/0x10
[ 3256.534257]    [<ffffffff802db8e7>] dispose_list+0x53/0x10e
[ 3256.534257]    [<ffffffff802dbd10>] invalidate_inodes+0x119/0x137
[ 3256.534257]    [<ffffffff802edeaf>] __invalidate_device+0x30/0x4e
[ 3256.534257]    [<ffffffff8034d652>] invalidate_partition+0x27/0x3d
[ 3256.534257]    [<ffffffff80316b2b>] del_gendisk+0x6e/0x121
[ 3256.534257]    [<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod]
[ 3256.534257]    [<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f
[scsi_mod] [ 3256.534257]    [<ffffffff803d2ce8>]
__device_release_driver+0x80/0xa5 [ 3256.534257]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b [ 3256.534257]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd [ 3256.534257]
[<ffffffff803d066e>] device_del+0x138/0x177 [ 3256.534257]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.534257]    [<ffffffffa009da02>] scsi_forget_host+0x42/0x6a
[scsi_mod] [ 3256.534257]    [<ffffffffa00978b3>]
scsi_remove_host+0x90/0x115 [scsi_mod] [ 3256.534257]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.534257]    [<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24
[usb_storage] [ 3256.534257]    [<ffffffffa000c030>]
usb_unbind_interface+0x63/0xf3 [usbcore] [ 3256.534257]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534257]    [<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534257]    [<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534257]    [<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534257]    [<ffffffffa00090c5>] usb_disable_device+0x106/0x182
[usbcore] [ 3256.534257]    [<ffffffffa00039f3>]
usb_disconnect+0xcf/0x148 [usbcore] [ 3256.534257]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534257]    [<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]  ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c1460>] cache_flusharray+0x5a/0x10f [ 3256.534257]
[<ffffffff802c0e0e>] kmem_cache_free+0x19e/0x244 [ 3256.534257]
[<ffffffffa036e4c7>] ext2_destroy_inode+0x17/0x19 [ext2]
[ 3256.534257]    [<ffffffff802db87f>] destroy_inode+0x32/0x47
[ 3256.534257]    [<ffffffff802db96e>] dispose_list+0xda/0x10e
[ 3256.534257]    [<ffffffff802dbd10>] invalidate_inodes+0x119/0x137
[ 3256.534257]    [<ffffffff802edeaf>] __invalidate_device+0x30/0x4e
[ 3256.534257]    [<ffffffff8034d652>] invalidate_partition+0x27/0x3d
[ 3256.534257]    [<ffffffff80316b2b>] del_gendisk+0x6e/0x121
[ 3256.534257]    [<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod]
[ 3256.534257]    [<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f
[scsi_mod] [ 3256.534257]    [<ffffffff803d2ce8>]
__device_release_driver+0x80/0xa5 [ 3256.534257]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b [ 3256.534257]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd [ 3256.534257]
[<ffffffff803d066e>] device_del+0x138/0x177 [ 3256.534257]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.534257]    [<ffffffffa009da02>] scsi_forget_host+0x42/0x6a
[scsi_mod] [ 3256.534257]    [<ffffffffa00978b3>]
scsi_remove_host+0x90/0x115 [scsi_mod] [ 3256.534257]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.534257]    [<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24
[usb_storage] [ 3256.534257]    [<ffffffffa000c030>]
usb_unbind_interface+0x63/0xf3 [usbcore] [ 3256.534257]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534257]    [<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534257]    [<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534257]    [<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534257]    [<ffffffffa00090c5>] usb_disable_device+0x106/0x182
[usbcore] [ 3256.534257]    [<ffffffffa00039f3>]
usb_disconnect+0xcf/0x148 [usbcore] [ 3256.534257]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534257]    [<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]  -> (&ei->cache_lru_lock){+.+...} ops:
1144 { [ 3256.534257]     HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffffa0341288>] fat_get_cluster+0x80/0x280 [fat]
[ 3256.534257]
[<ffffffffa0347682>] fat_fill_super+0xaf1/0xc6a [fat]
[ 3256.534257]
[<ffffffffa02b0198>] vfat_fill_super+0x1e/0x55 [vfat]
[ 3256.534257]
[<ffffffff802cb652>] get_sb_bdev+0x126/0x179
[ 3256.534257]
[<ffffffffa02b0178>] vfat_get_sb+0x13/0x15 [vfat]
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca271>] do_kern_mount+0x47/0xe2
[ 3256.534257]
[<ffffffff802e0b87>] do_mount+0x6ea/0x735
[ 3256.534257]
[<ffffffff802e0c5b>] sys_mount+0x89/0xd6
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     SOFTIRQ-ON-W
at: [ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffffa0341288>] fat_get_cluster+0x80/0x280 [fat]
[ 3256.534257]
[<ffffffffa0347682>] fat_fill_super+0xaf1/0xc6a [fat]
[ 3256.534257]
[<ffffffffa02b0198>] vfat_fill_super+0x1e/0x55 [vfat]
[ 3256.534257]
[<ffffffff802cb652>] get_sb_bdev+0x126/0x179
[ 3256.534257]
[<ffffffffa02b0178>] vfat_get_sb+0x13/0x15 [vfat]
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca271>] do_kern_mount+0x47/0xe2
[ 3256.534257]
[<ffffffff802e0b87>] do_mount+0x6ea/0x735
[ 3256.534257]
[<ffffffff802e0c5b>] sys_mount+0x89/0xd6
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffffa0341288>] fat_get_cluster+0x80/0x280 [fat]
[ 3256.534257]
[<ffffffffa0347682>] fat_fill_super+0xaf1/0xc6a [fat]
[ 3256.534257]
[<ffffffffa02b0198>] vfat_fill_super+0x1e/0x55 [vfat]
[ 3256.534257]
[<ffffffff802cb652>] get_sb_bdev+0x126/0x179
[ 3256.534257]
[<ffffffffa02b0178>] vfat_get_sb+0x13/0x15 [vfat]
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca271>] do_kern_mount+0x47/0xe2
[ 3256.534257]
[<ffffffff802e0b87>] do_mount+0x6ea/0x735
[ 3256.534257]
[<ffffffff802e0c5b>] sys_mount+0x89/0xd6
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]   }
[ 3256.534257]   ... key      at: [<ffffffffa034d240>]
__key.26079+0x0/0xffffffffffffb64d [fat] [ 3256.534257]  ... acquired
at: [ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffffa03411ac>] fat_cache_inval_inode+0x23/0x7f
[fat] [ 3256.534257]    [<ffffffffa0346805>] fat_clear_inode+0x11/0x1e
[fat] [ 3256.534257]    [<ffffffff802db6ba>] clear_inode+0xa2/0xfb
[ 3256.534257]    [<ffffffff802db8ef>] dispose_list+0x5b/0x10e
[ 3256.534257]    [<ffffffff802dbd10>] invalidate_inodes+0x119/0x137
[ 3256.534257]    [<ffffffff802edeaf>] __invalidate_device+0x30/0x4e
[ 3256.534257]    [<ffffffff8034d652>] invalidate_partition+0x27/0x3d
[ 3256.534257]    [<ffffffff80316af6>] del_gendisk+0x39/0x121
[ 3256.534257]    [<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod]
[ 3256.534257]    [<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f
[scsi_mod] [ 3256.534257]    [<ffffffff803d2ce8>]
__device_release_driver+0x80/0xa5 [ 3256.534257]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b [ 3256.534257]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd [ 3256.534257]
[<ffffffff803d066e>] device_del+0x138/0x177 [ 3256.534257]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.534257]    [<ffffffffa009da02>] scsi_forget_host+0x42/0x6a
[scsi_mod] [ 3256.534257]    [<ffffffffa00978b3>]
scsi_remove_host+0x90/0x115 [scsi_mod] [ 3256.534257]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.534257]    [<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24
[usb_storage] [ 3256.534257]    [<ffffffffa000c030>]
usb_unbind_interface+0x63/0xf3 [usbcore] [ 3256.534257]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534257]    [<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534257]    [<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534257]    [<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534257]    [<ffffffffa00090c5>] usb_disable_device+0x106/0x182
[usbcore] [ 3256.534257]    [<ffffffffa00039f3>]
usb_disconnect+0xcf/0x148 [usbcore] [ 3256.534257]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534257]    [<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]  -> (&sbi->inode_hash_lock){+.+...} ops:
3135 { [ 3256.534257]     HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffffa0347bdf>] fat_iget+0x30/0x91 [fat]
[ 3256.534257]
[<ffffffffa0342da2>] __fat_readdir+0xa99/0xb9d [fat]
[ 3256.534257]
[<ffffffffa0343011>] fat_readdir+0x23/0x25 [fat]
[ 3256.534257]
[<ffffffff802d63b3>] vfs_readdir+0x6c/0xa1
[ 3256.534257]
[<ffffffff802d6526>] sys_getdents+0x7d/0xc9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     SOFTIRQ-ON-W
at: [ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffffa0347bdf>] fat_iget+0x30/0x91 [fat]
[ 3256.534257]
[<ffffffffa0342da2>] __fat_readdir+0xa99/0xb9d [fat]
[ 3256.534257]
[<ffffffffa0343011>] fat_readdir+0x23/0x25 [fat]
[ 3256.534257]
[<ffffffff802d63b3>] vfs_readdir+0x6c/0xa1
[ 3256.534257]
[<ffffffff802d6526>] sys_getdents+0x7d/0xc9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffffa0347bdf>] fat_iget+0x30/0x91 [fat]
[ 3256.534257]
[<ffffffffa0342da2>] __fat_readdir+0xa99/0xb9d [fat]
[ 3256.534257]
[<ffffffffa0343011>] fat_readdir+0x23/0x25 [fat]
[ 3256.534257]
[<ffffffff802d63b3>] vfs_readdir+0x6c/0xa1
[ 3256.534257]
[<ffffffff802d6526>] sys_getdents+0x7d/0xc9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]   }
[ 3256.534257]   ... key      at: [<ffffffffa034d248>]
__key.25806+0x0/0xffffffffffffb645 [fat] [ 3256.534257]   ... acquired
at: [ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff802dab9d>] igrab+0x18/0x40
[ 3256.534257]    [<ffffffffa0347c08>] fat_iget+0x59/0x91 [fat]
[ 3256.534257]    [<ffffffffa0342da2>] __fat_readdir+0xa99/0xb9d [fat]
[ 3256.534257]    [<ffffffffa0343011>] fat_readdir+0x23/0x25 [fat]
[ 3256.534257]    [<ffffffff802d63b3>] vfs_readdir+0x6c/0xa1
[ 3256.534257]    [<ffffffff802d6526>] sys_getdents+0x7d/0xc9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]  ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffffa034647e>] fat_detach+0x27/0x65 [fat] [ 3256.534257]
[<ffffffffa034680d>] fat_clear_inode+0x19/0x1e [fat] [ 3256.534257]
[<ffffffff802db6ba>] clear_inode+0xa2/0xfb [ 3256.534257]
[<ffffffff802db8ef>] dispose_list+0x5b/0x10e [ 3256.534257]
[<ffffffff802dbd10>] invalidate_inodes+0x119/0x137 [ 3256.534257]
[<ffffffff802edeaf>] __invalidate_device+0x30/0x4e [ 3256.534257]
[<ffffffff8034d652>] invalidate_partition+0x27/0x3d [ 3256.534257]
[<ffffffff80316af6>] del_gendisk+0x39/0x121 [ 3256.534257]
[<ffffffffa00c0531>] sd_remove+0x2f/0x70 [sd_mod] [ 3256.534257]
[<ffffffffa00a0217>] scsi_bus_remove+0x38/0x3f [scsi_mod]
[ 3256.534257]    [<ffffffff803d2ce8>]
__device_release_driver+0x80/0xa5 [ 3256.534257]
[<ffffffff803d2de1>] device_release_driver+0x1e/0x2b [ 3256.534257]
[<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd [ 3256.534257]
[<ffffffff803d066e>] device_del+0x138/0x177 [ 3256.534257]
[<ffffffffa00a0508>] __scsi_remove_device+0x44/0x81 [scsi_mod]
[ 3256.534257]    [<ffffffffa009da02>] scsi_forget_host+0x42/0x6a
[scsi_mod] [ 3256.534257]    [<ffffffffa00978b3>]
scsi_remove_host+0x90/0x115 [scsi_mod] [ 3256.534257]
[<ffffffffa0351c08>] quiesce_and_remove_host+0x70/0xae [usb_storage]
[ 3256.534257]    [<ffffffffa0351d1e>] usb_stor_disconnect+0x18/0x24
[usb_storage] [ 3256.534257]    [<ffffffffa000c030>]
usb_unbind_interface+0x63/0xf3 [usbcore] [ 3256.534257]
[<ffffffff803d2ce8>] __device_release_driver+0x80/0xa5
[ 3256.534257]    [<ffffffff803d2de1>] device_release_driver+0x1e/0x2b
[ 3256.534257]    [<ffffffff803d22b1>] bus_remove_device+0xdb/0xfd
[ 3256.534257]    [<ffffffff803d066e>] device_del+0x138/0x177
[ 3256.534257]    [<ffffffffa00090c5>] usb_disable_device+0x106/0x182
[usbcore] [ 3256.534257]    [<ffffffffa00039f3>]
usb_disconnect+0xcf/0x148 [usbcore] [ 3256.534257]
[<ffffffffa000520a>] hub_thread+0x844/0x1446 [usbcore]
[ 3256.534257]    [<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257] [ 3256.534257] the second lock's
dependencies: [ 3256.534257] -> (&inode->inotify_mutex){+.+.+.} ops:
20622 { [ 3256.534257]    HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f342a>] inotify_inode_is_dead+0x30/0x94
[ 3256.534257]
[<ffffffff802d818b>] dentry_iput+0x82/0xc1
[ 3256.534257]
[<ffffffff802d9c08>] d_delete+0x56/0xce
[ 3256.534257]
[<ffffffff802d1a68>] vfs_unlink+0xe7/0xfb
[ 3256.534257]
[<ffffffff802d3aa0>] do_unlinkat+0xcd/0x164
[ 3256.534257]
[<ffffffff802d3b48>] sys_unlink+0x11/0x13
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    SOFTIRQ-ON-W
at: [ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f342a>] inotify_inode_is_dead+0x30/0x94
[ 3256.534257]
[<ffffffff802d818b>] dentry_iput+0x82/0xc1
[ 3256.534257]
[<ffffffff802d9c08>] d_delete+0x56/0xce
[ 3256.534257]
[<ffffffff802d1a68>] vfs_unlink+0xe7/0xfb
[ 3256.534257]
[<ffffffff802d3aa0>] do_unlinkat+0xcd/0x164
[ 3256.534257]
[<ffffffff802d3b48>] sys_unlink+0x11/0x13
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
RECLAIM_FS-ON-W at:
[ 3256.534257]
[<ffffffff80265707>] mark_held_locks+0x4d/0x6b
[ 3256.534257]
[<ffffffff802657de>] lockdep_trace_alloc+0xb9/0xdb
[ 3256.534257]
[<ffffffff802c35db>] __kmalloc+0x70/0x27c
[ 3256.534257]
[<ffffffff802f43e2>] kernel_event+0xa7/0x10e
[ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]
[<ffffffff802f334a>] inotify_inode_queue_event+0xab/0xe0
[ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]
[<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a
[ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72
[ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f342a>] inotify_inode_is_dead+0x30/0x94
[ 3256.534257]
[<ffffffff802d818b>] dentry_iput+0x82/0xc1
[ 3256.534257]
[<ffffffff802d9c08>] d_delete+0x56/0xce
[ 3256.534257]
[<ffffffff802d1a68>] vfs_unlink+0xe7/0xfb
[ 3256.534257]
[<ffffffff802d3aa0>] do_unlinkat+0xcd/0x164
[ 3256.534257]
[<ffffffff802d3b48>] sys_unlink+0x11/0x13
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]  }
[ 3256.534257]  ... key      at: [<ffffffff8116cec0>]
__key.28886+0x0/0x8 [ 3256.534257]  -> (&ih->mutex){+.+.+.} ops: 3354
{ [ 3256.534257]     HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]
[<ffffffff802f406f>] sys_inotify_add_watch+0x19d/0x1a9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     SOFTIRQ-ON-W
at: [ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]
[<ffffffff802f406f>] sys_inotify_add_watch+0x19d/0x1a9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
RECLAIM_FS-ON-W at:
[ 3256.534257]
[<ffffffff80265707>] mark_held_locks+0x4d/0x6b
[ 3256.534257]
[<ffffffff802657de>] lockdep_trace_alloc+0xb9/0xdb
[ 3256.534257]
[<ffffffff802c35db>] __kmalloc+0x70/0x27c
[ 3256.534257]
[<ffffffff802f43e2>] kernel_event+0xa7/0x10e
[ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]
[<ffffffff802f334a>] inotify_inode_queue_event+0xab/0xe0
[ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]
[<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a
[ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72
[ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]
[<ffffffff802f406f>] sys_inotify_add_watch+0x19d/0x1a9
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]   }
[ 3256.534257]   ... key      at: [<ffffffff8116d280>]
__key.20753+0x0/0x8 [ 3256.534257]   -> (&idp->lock){......} ops: 829
{ [ 3256.534257]      INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]
[<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]
[<ffffffff80320d40>] devpts_new_index+0x30/0xb0
[ 3256.534257]
[<ffffffff803b3056>] ptmx_open+0x29/0xef
[ 3256.534257]
[<ffffffff802cbbfc>] chrdev_open+0x197/0x1b8
[ 3256.534257]
[<ffffffff802c74fa>] __dentry_open+0x174/0x299
[ 3256.534257]
[<ffffffff802c76ec>] nameidata_to_filp+0x41/0x52
[ 3256.534257]
[<ffffffff802d4679>] do_filp_open+0x411/0x842
[ 3256.534257]
[<ffffffff802c72c2>] do_sys_open+0x53/0xda
[ 3256.534257]
[<ffffffff802c7372>] sys_open+0x1b/0x1d
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff8116fd30>]
__key.12838+0x0/0x8 [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff80355955>] idr_pre_get+0x41/0x75 [ 3256.534257]
[<ffffffff802f2dca>] inotify_handle_get_wd+0x24/0x65 [ 3256.534257]
[<ffffffff802f3014>] inotify_add_watch+0x5f/0x111 [ 3256.534257]
[<ffffffff802f3ff2>] sys_inotify_add_watch+0x120/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]   -> (&parent->list_lock){-.-.-.} ops:
477163 { [ 3256.534257]      IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802c1460>] cache_flusharray+0x5a/0x10f
[ 3256.534257]
[<ffffffff802c0e0e>] kmem_cache_free+0x19e/0x244
[ 3256.534257]
[<ffffffff802e8251>] free_buffer_head+0x29/0x75
[ 3256.534257]
[<ffffffff802e8847>] try_to_free_buffers+0x8d/0xa4
[ 3256.534257]
[<ffffffffa0060c92>] journal_try_to_free_buffers+0x19a/0x1fc [jbd]
[ 3256.534257]
[<ffffffffa007d9cb>] bdev_try_to_free_page+0x5f/0x75 [ext3]
[ 3256.534257]
[<ffffffff802ee853>] blkdev_releasepage+0x31/0x3d
[ 3256.534257]
[<ffffffff802925ab>] try_to_release_page+0x32/0x3b
[ 3256.534257]
[<ffffffff8029ed2f>] shrink_page_list+0x529/0x736
[ 3256.534257]
[<ffffffff8029f5a7>] shrink_list+0x2aa/0x62a
[ 3256.534257]
[<ffffffff8029fbab>] shrink_zone+0x284/0x32e
[ 3256.534257]
[<ffffffff802a0553>] kswapd+0x4cc/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305
[ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c
[ 3256.534257]
[<ffffffff802c48a7>] kmem_cache_create+0x26c/0x535
[ 3256.534257]
[<ffffffff8069e371>] kmem_cache_init+0x1e6/0x688
[ 3256.534257]
[<ffffffff80684bf0>] start_kernel+0x303/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff8116c4a8>]
__key.25650+0x0/0x8 [ 3256.534257]    -> (&zone->lock){..-.-.} ops:
44576 { [ 3256.534257]       IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80297824>] free_pages_bulk+0x2d/0x2d4
[ 3256.534257]
[<ffffffff80298faf>] free_hot_cold_page+0x194/0x2c0
[ 3256.534257]
[<ffffffff80299104>] __pagevec_free+0x29/0x3d
[ 3256.534257]
[<ffffffff8029eddf>] shrink_page_list+0x5d9/0x736
[ 3256.534257]
[<ffffffff8029f5a7>] shrink_list+0x2aa/0x62a
[ 3256.534257]
[<ffffffff8029fbab>] shrink_zone+0x284/0x32e
[ 3256.534257]
[<ffffffff802a0553>] kswapd+0x4cc/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80297824>] free_pages_bulk+0x2d/0x2d4
[ 3256.534257]
[<ffffffff80298faf>] free_hot_cold_page+0x194/0x2c0
[ 3256.534257]
[<ffffffff80299133>] free_hot_page+0xb/0xd
[ 3256.534257]
[<ffffffff8029915b>] __free_pages+0x26/0x2f
[ 3256.534257]
[<ffffffff806b46c9>] __free_pages_bootmem+0x7e/0x80
[ 3256.534257]
[<ffffffff8069be44>] free_all_bootmem_core+0xf3/0x1c2
[ 3256.534257]
[<ffffffff8069bf3c>] free_all_bootmem_node+0x10/0x12
[ 3256.534257]
[<ffffffff80695ecf>] numa_free_all_bootmem+0x46/0x79
[ 3256.534257]
[<ffffffff80694fc7>] mem_init+0x1e/0x161
[ 3256.534257]
[<ffffffff80684bdc>] start_kernel+0x2ef/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff81169130>]
__key.31693+0x0/0x8 [ 3256.534257]    ... acquired at:
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    -> (&on_slab_l3_key){-.-.-.} ops:
30124 { [ 3256.534257]       IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802c1460>] cache_flusharray+0x5a/0x10f
[ 3256.534257]
[<ffffffff802c0e0e>] kmem_cache_free+0x19e/0x244
[ 3256.534257]
[<ffffffff802c100c>] slab_destroy+0x158/0x167
[ 3256.534257]
[<ffffffff802c1191>] free_block+0x176/0x1cb
[ 3256.534257]
[<ffffffff802c14a8>] cache_flusharray+0xa2/0x10f
[ 3256.534257]
[<ffffffff802c0e0e>] kmem_cache_free+0x19e/0x244
[ 3256.534257]
[<ffffffff802db890>] destroy_inode+0x43/0x47
[ 3256.534257]
[<ffffffff802dbe8f>] generic_delete_inode+0x161/0x173
[ 3256.534257]
[<ffffffff802daf42>] iput+0x61/0x65
[ 3256.534257]
[<ffffffff8031b5ba>] sysfs_d_iput+0x2f/0x34
[ 3256.534257]
[<ffffffff802d81a8>] dentry_iput+0x9f/0xc1
[ 3256.534257]
[<ffffffff802d82af>] d_kill+0x40/0x60
[ 3256.534257]
[<ffffffff802d8574>] __shrink_dcache_sb+0x2a5/0x33d
[ 3256.534257]
[<ffffffff802d86fd>] shrink_dcache_memory+0xf1/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305
[ 3256.534257]
[<ffffffff802c2d67>] kmem_cache_alloc_node_notrace+0x10e/0x191
[ 3256.534257]
[<ffffffff802c40a2>] do_tune_cpucache+0x375/0x504
[ 3256.534257]
[<ffffffff802c43bd>] enable_cpucache+0x60/0xa2
[ 3256.534257]
[<ffffffff804791d4>] setup_cpu_cache+0x24/0x2a9
[ 3256.534257]
[<ffffffff802c4afd>] kmem_cache_create+0x4c2/0x535
[ 3256.534257]
[<ffffffff806a3ea8>] idr_init_cache+0x1f/0x28
[ 3256.534257]
[<ffffffff80684bfa>] start_kernel+0x30d/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff8116c4d0>]
on_slab_l3_key+0x0/0x8 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c [ 3256.534257]
[<ffffffff80355941>] idr_pre_get+0x2d/0x75 [ 3256.534257]
[<ffffffff802f2dca>] inotify_handle_get_wd+0x24/0x65 [ 3256.534257]
[<ffffffff802f3014>] inotify_add_watch+0x5f/0x111 [ 3256.534257]
[<ffffffff802f3ff2>] sys_inotify_add_watch+0x120/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c20c5>] kmem_cache_alloc_node+0x112/0x214
[ 3256.534257]    [<ffffffff802c22ce>] cache_grow+0x107/0x3dc
[ 3256.534257]    [<ffffffff802c2859>] cache_alloc_refill+0x2b6/0x305
[ 3256.534257]    [<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c
[ 3256.534257]    [<ffffffff80355941>] idr_pre_get+0x2d/0x75
[ 3256.534257]    [<ffffffff802f2dca>] inotify_handle_get_wd+0x24/0x65
[ 3256.534257]    [<ffffffff802f3014>] inotify_add_watch+0x5f/0x111
[ 3256.534257]    [<ffffffff802f3ff2>]
sys_inotify_add_watch+0x120/0x1a9 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257] [ 3256.534257]
-> (inode_lock){+.+.-.} ops: 128828 { [ 3256.534257]      HARDIRQ-ON-W
at: [ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802db379>] ifind_fast+0x22/0x9d
[ 3256.534257]
[<ffffffff802dc2fa>] iget_locked+0x39/0x171
[ 3256.534257]
[<ffffffff80319b94>] sysfs_get_inode+0x1a/0x1f3
[ 3256.534257]
[<ffffffff8031c307>] sysfs_fill_super+0x51/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802db379>] ifind_fast+0x22/0x9d
[ 3256.534257]
[<ffffffff802dc2fa>] iget_locked+0x39/0x171
[ 3256.534257]
[<ffffffff80319b94>] sysfs_get_inode+0x1a/0x1f3
[ 3256.534257]
[<ffffffff8031c307>] sysfs_fill_super+0x51/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80354aa0>] _atomic_dec_and_lock+0x34/0x54
[ 3256.534257]
[<ffffffff802daf10>] iput+0x2f/0x65
[ 3256.534257]
[<ffffffff8031b5ba>] sysfs_d_iput+0x2f/0x34
[ 3256.534257]
[<ffffffff802d81a8>] dentry_iput+0x9f/0xc1
[ 3256.534257]
[<ffffffff802d82af>] d_kill+0x40/0x60
[ 3256.534257]
[<ffffffff802d8574>] __shrink_dcache_sb+0x2a5/0x33d
[ 3256.534257]
[<ffffffff802d86fd>] shrink_dcache_memory+0xf1/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802db379>] ifind_fast+0x22/0x9d
[ 3256.534257]
[<ffffffff802dc2fa>] iget_locked+0x39/0x171
[ 3256.534257]
[<ffffffff80319b94>] sysfs_get_inode+0x1a/0x1f3
[ 3256.534257]
[<ffffffff8031c307>] sysfs_fill_super+0x51/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff806132f8>]
inode_lock+0x18/0x40 [ 3256.534257]   ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff802dab9d>] igrab+0x18/0x40
[ 3256.534257]    [<ffffffff802f3040>] inotify_add_watch+0x8b/0x111
[ 3256.534257]    [<ffffffff802f3ff2>]
sys_inotify_add_watch+0x120/0x1a9 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257] [ 3256.534257]
-> (dcache_lock){+.+.-.} ops: 1141689 { [ 3256.534257]
HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d9f1a>] d_alloc+0x18d/0x1de
[ 3256.534257]
[<ffffffff802d9f8a>] d_alloc_root+0x1f/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d9f1a>] d_alloc+0x18d/0x1de
[ 3256.534257]
[<ffffffff802d9f8a>] d_alloc_root+0x1f/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d8650>] shrink_dcache_memory+0x44/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d9f1a>] d_alloc+0x18d/0x1de
[ 3256.534257]
[<ffffffff802d9f8a>] d_alloc_root+0x1f/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff80676398>]
dcache_lock+0x18/0x40 [ 3256.534257]    -> (&dentry->d_lock){+.+.-.}
ops: 2150925 { [ 3256.534257]       HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802f2c0a>] inotify_d_instantiate+0x1b/0x49
[ 3256.534257]
[<ffffffff802d912a>] __d_instantiate+0x37/0x39
[ 3256.534257]
[<ffffffff802d9164>] d_instantiate+0x38/0x49
[ 3256.534257]
[<ffffffff802d9fb0>] d_alloc_root+0x45/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802f2c0a>] inotify_d_instantiate+0x1b/0x49
[ 3256.534257]
[<ffffffff802d912a>] __d_instantiate+0x37/0x39
[ 3256.534257]
[<ffffffff802d9164>] d_instantiate+0x38/0x49
[ 3256.534257]
[<ffffffff802d9fb0>] d_alloc_root+0x45/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d83b6>] __shrink_dcache_sb+0xe7/0x33d
[ 3256.534257]
[<ffffffff802d86fd>] shrink_dcache_memory+0xf1/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802f2c0a>] inotify_d_instantiate+0x1b/0x49
[ 3256.534257]
[<ffffffff802d912a>] __d_instantiate+0x37/0x39
[ 3256.534257]
[<ffffffff802d9164>] d_instantiate+0x38/0x49
[ 3256.534257]
[<ffffffff802d9fb0>] d_alloc_root+0x45/0x4d
[ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba
[ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff8116ce80>]
__key.28008+0x0/0x10 [ 3256.534257]     -> (sysctl_lock){+.+.-.} ops:
22882 { [ 3256.534257]        HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80248d45>] __sysctl_head_next+0x1f/0xd3
[ 3256.534257]
[<ffffffff8025cfb6>] sysctl_check_lookup+0xcd/0xf5
[ 3256.534257]
[<ffffffff8025d1ba>] sysctl_check_table+0x189/0x566
[ 3256.534257]
[<ffffffff80248abf>] __register_sysctl_paths+0xee/0x29e
[ 3256.534257]
[<ffffffff80248c98>] register_sysctl_paths+0x29/0x2b
[ 3256.534257]
[<ffffffff80248cad>] register_sysctl_table+0x13/0x15
[ 3256.534257]
[<ffffffff8023758b>] register_sched_domain_sysctl+0x42a/0x440
[ 3256.534257]
[<ffffffff8069878f>] sched_init_smp+0x12e/0x242
[ 3256.534257]
[<ffffffff80684631>] kernel_init+0x111/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80248d45>] __sysctl_head_next+0x1f/0xd3
[ 3256.534257]
[<ffffffff8025cfb6>] sysctl_check_lookup+0xcd/0xf5
[ 3256.534257]
[<ffffffff8025d1ba>] sysctl_check_table+0x189/0x566
[ 3256.534257]
[<ffffffff80248abf>] __register_sysctl_paths+0xee/0x29e
[ 3256.534257]
[<ffffffff80248c98>] register_sysctl_paths+0x29/0x2b
[ 3256.534257]
[<ffffffff80248cad>] register_sysctl_table+0x13/0x15
[ 3256.534257]
[<ffffffff8023758b>] register_sched_domain_sysctl+0x42a/0x440
[ 3256.534257]
[<ffffffff8069878f>] sched_init_smp+0x12e/0x242
[ 3256.534257]
[<ffffffff80684631>] kernel_init+0x111/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802488b1>] sysctl_head_put+0x18/0x3d
[ 3256.534257]
[<ffffffff8030dd80>] proc_delete_inode+0x3f/0x4c
[ 3256.534257]
[<ffffffff802dbe0e>] generic_delete_inode+0xe0/0x173
[ 3256.534257]
[<ffffffff802daf42>] iput+0x61/0x65
[ 3256.534257]
[<ffffffff802d81b2>] dentry_iput+0xa9/0xc1
[ 3256.534257]
[<ffffffff802d82af>] d_kill+0x40/0x60
[ 3256.534257]
[<ffffffff802d8574>] __shrink_dcache_sb+0x2a5/0x33d
[ 3256.534257]
[<ffffffff802d86fd>] shrink_dcache_memory+0xf1/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0d4f>] try_to_free_pages+0x26c/0x36a
[ 3256.534257]
[<ffffffff80299f7a>] __alloc_pages_internal+0x2a3/0x459
[ 3256.534257]
[<ffffffff802be38f>] alloc_page_vma+0x17b/0x198
[ 3256.534257]
[<ffffffff802a98cc>] handle_mm_fault+0x24a/0x709
[ 3256.534257]
[<ffffffff80227fd3>] do_page_fault+0x207/0x21e
[ 3256.534257]
[<ffffffff8048d055>] page_fault+0x25/0x30
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80248d45>] __sysctl_head_next+0x1f/0xd3
[ 3256.534257]
[<ffffffff8025cfb6>] sysctl_check_lookup+0xcd/0xf5
[ 3256.534257]
[<ffffffff8025d1ba>] sysctl_check_table+0x189/0x566
[ 3256.534257]
[<ffffffff80248abf>] __register_sysctl_paths+0xee/0x29e
[ 3256.534257]
[<ffffffff80248c98>] register_sysctl_paths+0x29/0x2b
[ 3256.534257]
[<ffffffff80248cad>] register_sysctl_table+0x13/0x15
[ 3256.534257]
[<ffffffff8023758b>] register_sched_domain_sysctl+0x42a/0x440
[ 3256.534257]
[<ffffffff8069878f>] sched_init_smp+0x12e/0x242
[ 3256.534257]
[<ffffffff80684631>] kernel_init+0x111/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff80607f98>]
sysctl_lock+0x18/0x40 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff802487ac>] sysctl_is_seen+0x23/0x58
[ 3256.534257]    [<ffffffff80314f49>] proc_sys_compare+0x37/0x4a
[ 3256.534257]    [<ffffffff802d9a58>] __d_lookup+0xf2/0x195
[ 3256.534257]    [<ffffffff802d0fc6>] __lookup_hash+0x52/0x126
[ 3256.534257]    [<ffffffff802d10cf>] lookup_hash+0x35/0x40
[ 3256.534257]    [<ffffffff802d43e3>] do_filp_open+0x17b/0x842
[ 3256.534257]    [<ffffffff802c72c2>] do_sys_open+0x53/0xda
[ 3256.534257]    [<ffffffff802c7372>] sys_open+0x1b/0x1d
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     -> (&dentry->d_lock/1){+.+...} ops:
309 { [ 3256.534257]        HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c650>] _spin_lock_nested+0x3f/0x73
[ 3256.534257]
[<ffffffff802d950f>] d_move_locked+0x6d/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c650>] _spin_lock_nested+0x3f/0x73
[ 3256.534257]
[<ffffffff802d950f>] d_move_locked+0x6d/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c650>] _spin_lock_nested+0x3f/0x73
[ 3256.534257]
[<ffffffff802d950f>] d_move_locked+0x6d/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff8116ce81>]
__key.28008+0x1/0x10 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c650>] _spin_lock_nested+0x3f/0x73
[ 3256.534257]    [<ffffffff802d950f>] d_move_locked+0x6d/0x25c
[ 3256.534257]    [<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]    [<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]    [<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]    [<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802f2c0a>] inotify_d_instantiate+0x1b/0x49 [ 3256.534257]
[<ffffffff802d912a>] __d_instantiate+0x37/0x39 [ 3256.534257]
[<ffffffff802d9164>] d_instantiate+0x38/0x49 [ 3256.534257]
[<ffffffff802d9fb0>] d_alloc_root+0x45/0x4d [ 3256.534257]
[<ffffffff8031c333>] sysfs_fill_super+0x7d/0xba [ 3256.534257]
[<ffffffff802cb446>] get_sb_single+0x61/0xb2 [ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18 [ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99 [ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16 [ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8 [ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271 [ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e [ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398 [ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]    [<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    -> (vfsmount_lock){+.+...} ops: 154348
{ [ 3256.534257]       HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802dfce2>] alloc_vfsmnt+0x4f/0x14c
[ 3256.534257]
[<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802dfce2>] alloc_vfsmnt+0x4f/0x14c
[ 3256.534257]
[<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802dfce2>] alloc_vfsmnt+0x4f/0x14c
[ 3256.534257]
[<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff80676458>]
vfsmount_lock+0x18/0x40 [ 3256.534257]     -> (mnt_id_ida.lock){......}
ops: 98 { [ 3256.534257]        INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]
[<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]
[<ffffffff802dfcd6>] alloc_vfsmnt+0x43/0x14c
[ 3256.534257]
[<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff80613850>]
mnt_id_ida+0x30/0x60 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80355029>] get_from_free_list+0x1c/0x50
[ 3256.534257]    [<ffffffff803550f2>] idr_get_empty_slot+0x2f/0x24d
[ 3256.534257]    [<ffffffff80355353>] ida_get_new_above+0x43/0x1b4
[ 3256.534257]    [<ffffffff803554d2>] ida_get_new+0xe/0x10
[ 3256.534257]    [<ffffffff802dfcf1>] alloc_vfsmnt+0x5e/0x14c
[ 3256.534257]    [<ffffffff802ca1b2>] vfs_kern_mount+0x37/0x99
[ 3256.534257]    [<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]    [<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]    [<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]    [<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]    [<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     -> (&q->lock){-.-.-.} ops: 14667692
{ [ 3256.534257]        IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff8025651f>] prepare_to_wait+0x1e/0x69
[ 3256.534257]
[<ffffffff802a0179>] kswapd+0xf2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c
[ 3256.534257]
[<ffffffff80488c36>] wait_for_common+0x37/0x142
[ 3256.534257]
[<ffffffff80488dcb>] wait_for_completion+0x18/0x1a
[ 3256.534257]
[<ffffffff802561b9>] kthread_create+0xac/0x143
[ 3256.534257]
[<ffffffff8048616b>] migration_call+0x47/0x4cc
[ 3256.534257]
[<ffffffff806980b0>] migration_init+0x22/0x58
[ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185
[ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff809f2a68>]
__key.19384+0x0/0x8 [ 3256.534257]      -> (&rq->lock){-.-.-.} ops:
4747559 { [ 3256.534257]         IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80231c89>] task_rq_lock+0x4c/0x7e
[ 3256.534257]
[<ffffffff80239d54>] set_cpus_allowed_ptr+0x1f/0x118
[ 3256.534257]
[<ffffffff802a0102>] kswapd+0x7b/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff802368eb>] rq_attach_root+0x16/0xcb
[ 3256.534257]
[<ffffffff806984d9>] sched_init+0x3f3/0x57b
[ 3256.534257]
[<ffffffff80684a34>] start_kernel+0x147/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       }
[ 3256.534257]       ... key      at: [<ffffffff808ed4b0>]
__key.47760+0x0/0x8 [ 3256.534257]       -> (&vec->lock){..-...} ops:
2840 { [ 3256.534257]          IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]          INITIAL
USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80292234>] cpupri_set+0xce/0x130
[ 3256.534257]
[<ffffffff80234452>] rq_online_rt+0x6a/0x6f
[ 3256.534257]
[<ffffffff80230ebb>] set_rq_online+0x48/0x55
[ 3256.534257]
[<ffffffff80236976>] rq_attach_root+0xa1/0xcb
[ 3256.534257]
[<ffffffff806984d9>] sched_init+0x3f3/0x57b
[ 3256.534257]
[<ffffffff80684a34>] start_kernel+0x147/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        }
[ 3256.534257]        ... key      at: [<ffffffff811690a8>]
__key.16190+0x0/0x18 [ 3256.534257]       ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80292234>] cpupri_set+0xce/0x130
[ 3256.534257]    [<ffffffff80234452>] rq_online_rt+0x6a/0x6f
[ 3256.534257]    [<ffffffff80230ebb>] set_rq_online+0x48/0x55
[ 3256.534257]    [<ffffffff80236976>] rq_attach_root+0xa1/0xcb
[ 3256.534257]    [<ffffffff806984d9>] sched_init+0x3f3/0x57b
[ 3256.534257]    [<ffffffff80684a34>] start_kernel+0x147/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]       -> (&rt_b->rt_runtime_lock){..-...} ops: 125
{ [ 3256.534257]          IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]          INITIAL
USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff80234ba2>] enqueue_task_rt+0x1a6/0x266
[ 3256.534257]
[<ffffffff80230806>] enqueue_task+0x5b/0x66
[ 3256.534257]
[<ffffffff80230916>] activate_task+0x28/0x31
[ 3256.534257]
[<ffffffff80239bdf>] try_to_wake_up+0x1df/0x307
[ 3256.534257]
[<ffffffff80239d33>] wake_up_process+0x10/0x12
[ 3256.534257]
[<ffffffff804861fb>] migration_call+0xd7/0x4cc
[ 3256.534257]
[<ffffffff806980d2>] migration_init+0x44/0x58
[ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185
[ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        }
[ 3256.534257]        ... key      at: [<ffffffff808ed4b8>]
__key.38426+0x0/0x8 [ 3256.534257]        -> (&cpu_base->lock){-.-.-.}
ops: 5183672 { [ 3256.534257]           IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80259021>] lock_hrtimer_base+0x25/0x4b
[ 3256.534257]
[<ffffffff8025919e>] __hrtimer_start_range_ns+0x2c/0x22f
[ 3256.534257]
[<ffffffff80234bee>] enqueue_task_rt+0x1f2/0x266
[ 3256.534257]
[<ffffffff80230806>] enqueue_task+0x5b/0x66
[ 3256.534257]
[<ffffffff80230916>] activate_task+0x28/0x31
[ 3256.534257]
[<ffffffff80239bdf>] try_to_wake_up+0x1df/0x307
[ 3256.534257]
[<ffffffff80239d33>] wake_up_process+0x10/0x12
[ 3256.534257]
[<ffffffff804861fb>] migration_call+0xd7/0x4cc
[ 3256.534257]
[<ffffffff806980d2>] migration_init+0x44/0x58
[ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185
[ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         }
[ 3256.534257]         ... key      at: [<ffffffff809f2aa0>]
__key.21390+0x0/0x8 [ 3256.534257]        ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80259021>] lock_hrtimer_base+0x25/0x4b
[ 3256.534257]    [<ffffffff8025919e>]
__hrtimer_start_range_ns+0x2c/0x22f [ 3256.534257]
[<ffffffff80234bee>] enqueue_task_rt+0x1f2/0x266 [ 3256.534257]
[<ffffffff80230806>] enqueue_task+0x5b/0x66 [ 3256.534257]
[<ffffffff80230916>] activate_task+0x28/0x31 [ 3256.534257]
[<ffffffff80239bdf>] try_to_wake_up+0x1df/0x307 [ 3256.534257]
[<ffffffff80239d33>] wake_up_process+0x10/0x12 [ 3256.534257]
[<ffffffff804861fb>] migration_call+0xd7/0x4cc [ 3256.534257]
[<ffffffff806980d2>] migration_init+0x44/0x58 [ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185 [ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]        -> (&rt_rq->rt_runtime_lock){-.....} ops: 1621
{ [ 3256.534257]           IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802322fb>] update_curr_rt+0xbf/0x14e
[ 3256.534257]
[<ffffffff8023463c>] dequeue_task_rt+0x1f/0x7a
[ 3256.534257]
[<ffffffff802308e2>] dequeue_task+0xd1/0xdd
[ 3256.534257]
[<ffffffff80230947>] deactivate_task+0x28/0x31
[ 3256.534257]
[<ffffffff80488fab>] __schedule+0x1de/0xa17
[ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31
[ 3256.534257]
[<ffffffff8023e1a4>] migration_thread+0x1bb/0x267
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         }
[ 3256.534257]         ... key      at: [<ffffffff808ed4c0>]
__key.47715+0x0/0x8 [ 3256.534257]        ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff8023263e>] __enable_runtime+0x38/0x78
[ 3256.534257]    [<ffffffff80234436>] rq_online_rt+0x4e/0x6f
[ 3256.534257]    [<ffffffff80230ebb>] set_rq_online+0x48/0x55
[ 3256.534257]    [<ffffffff80486238>] migration_call+0x114/0x4cc
[ 3256.534257]    [<ffffffff8025a197>] notifier_call_chain+0x33/0x5b
[ 3256.534257]    [<ffffffff8025a22f>] raw_notifier_call_chain+0xf/0x11
[ 3256.534257]    [<ffffffff80486a21>] _cpu_up+0xe0/0x12f
[ 3256.534257]    [<ffffffff80486ad3>] cpu_up+0x63/0x78
[ 3256.534257]    [<ffffffff806845dd>] kernel_init+0xbd/0x189
[ 3256.534257]    [<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]       ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80234ba2>] enqueue_task_rt+0x1a6/0x266 [ 3256.534257]
[<ffffffff80230806>] enqueue_task+0x5b/0x66 [ 3256.534257]
[<ffffffff80230916>] activate_task+0x28/0x31 [ 3256.534257]
[<ffffffff80239bdf>] try_to_wake_up+0x1df/0x307 [ 3256.534257]
[<ffffffff80239d33>] wake_up_process+0x10/0x12 [ 3256.534257]
[<ffffffff804861fb>] migration_call+0xd7/0x4cc [ 3256.534257]
[<ffffffff806980d2>] migration_init+0x44/0x58 [ 3256.534257]
[<ffffffff80209076>] do_one_initcall+0x70/0x185 [ 3256.534257]
[<ffffffff80684584>] kernel_init+0x64/0x189 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]       ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802322fb>] update_curr_rt+0xbf/0x14e [ 3256.534257]
[<ffffffff8023463c>] dequeue_task_rt+0x1f/0x7a [ 3256.534257]
[<ffffffff802308e2>] dequeue_task+0xd1/0xdd [ 3256.534257]
[<ffffffff80230947>] deactivate_task+0x28/0x31 [ 3256.534257]
[<ffffffff80488fab>] __schedule+0x1de/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff8023e1a4>] migration_thread+0x1bb/0x267 [ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]       -> (&rq->lock/1){..-...} ops: 8988
{ [ 3256.534257]          IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]          INITIAL
USE at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        }
[ 3256.534257]        ... key      at: [<ffffffff808ed4b1>]
__key.47760+0x1/0x8 [ 3256.534257]        ->
(&sig->cputimer.lock){-.-...} ops: 8005 { [ 3256.534257]
IN-HARDIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-SOFTIRQ-W at:
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff8025721f>] thread_group_cputimer+0x2d/0xb6
[ 3256.534257]
[<ffffffff80258543>] posix_cpu_timers_exit_group+0x15/0x3b
[ 3256.534257]
[<ffffffff80243785>] release_task+0xd6/0x367
[ 3256.534257]
[<ffffffff80243eec>] wait_consider_task+0x4d6/0x8b6
[ 3256.534257]
[<ffffffff8024445c>] do_wait+0x190/0x3b6
[ 3256.534257]
[<ffffffff80244707>] sys_wait4+0x85/0x9f
[ 3256.534257]
[<ffffffff80251ad6>] wait_for_helper+0x42/0x6e
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]         }
[ 3256.534257]         ... key      at: [<ffffffff808ef650>]
__key.17080+0x0/0x8 [ 3256.534257]        ... acquired at:
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]       ... acquired at: [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]       ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80231dab>] update_curr+0xf0/0x109 [ 3256.534257]
[<ffffffff80232add>] dequeue_entity+0x1b/0x1e5 [ 3256.534257]
[<ffffffff80232ff8>] dequeue_task_fair+0x29/0x75 [ 3256.534257]
[<ffffffff802308e2>] dequeue_task+0xd1/0xdd [ 3256.534257]
[<ffffffff80230947>] deactivate_task+0x28/0x31 [ 3256.534257]
[<ffffffff80488fab>] __schedule+0x1de/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80244e5e>] do_exit+0x698/0x6a6 [ 3256.534257]
[<ffffffff80244eeb>] do_group_exit+0x7f/0xaf [ 3256.534257]
[<ffffffff80244f2d>] sys_exit_group+0x12/0x16 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]      ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80231c89>] task_rq_lock+0x4c/0x7e [ 3256.534257]
[<ffffffff80239a94>] try_to_wake_up+0x94/0x307 [ 3256.534257]
[<ffffffff80239d14>] default_wake_function+0xd/0xf [ 3256.534257]
[<ffffffff80230a7e>] __wake_up_common+0x46/0x76 [ 3256.534257]
[<ffffffff80231ad5>] complete+0x38/0x4c [ 3256.534257]
[<ffffffff80255e9a>] kthreadd+0xfe/0x12f [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]      -> (&ep->lock){......} ops: 20927
{ [ 3256.534257]         INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff802f546c>] sys_epoll_ctl+0x29e/0x4ac
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       }
[ 3256.534257]       ... key      at: [<ffffffff8116d2c0>]
__key.24119+0x0/0x10 [ 3256.534257]       ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff80231c89>] task_rq_lock+0x4c/0x7e
[ 3256.534257]    [<ffffffff80239a94>] try_to_wake_up+0x94/0x307
[ 3256.534257]    [<ffffffff80239d14>] default_wake_function+0xd/0xf
[ 3256.534257]    [<ffffffff80230a7e>] __wake_up_common+0x46/0x76
[ 3256.534257]    [<ffffffff80230ac1>] __wake_up_locked+0x13/0x15
[ 3256.534257]    [<ffffffff802f4dad>] ep_poll_callback+0xb4/0xf7
[ 3256.534257]    [<ffffffff80230a7e>] __wake_up_common+0x46/0x76
[ 3256.534257]    [<ffffffff80231b89>] __wake_up+0x38/0x50
[ 3256.534257]    [<ffffffff803afdc4>] n_tty_receive_buf+0xe6e/0xec2
[ 3256.534257]    [<ffffffff803b2851>] pty_write+0x39/0x43
[ 3256.534257]    [<ffffffff803ae3c9>] n_tty_write+0x260/0x38c
[ 3256.534257]    [<ffffffff803abcc5>] tty_write+0x18c/0x226
[ 3256.534257]    [<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]    [<ffffffff803abdc0>] redirected_tty_write+0x61/0x92
[ 3256.534257]    [<ffffffff802c93f0>] vfs_write+0xae/0x137
[ 3256.534257]    [<ffffffff802c953d>] sys_write+0x47/0x6e
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]      ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff802f4d17>] ep_poll_callback+0x1e/0xf7 [ 3256.534257]
[<ffffffff80230a7e>] __wake_up_common+0x46/0x76 [ 3256.534257]
[<ffffffff80231b89>] __wake_up+0x38/0x50 [ 3256.534257]
[<ffffffff803afdc4>] n_tty_receive_buf+0xe6e/0xec2 [ 3256.534257]
[<ffffffff803b2851>] pty_write+0x39/0x43 [ 3256.534257]
[<ffffffff803ae3c9>] n_tty_write+0x260/0x38c [ 3256.534257]
[<ffffffff803abcc5>] tty_write+0x18c/0x226 [ 3256.534257]
[<ffffffff802c93f0>] vfs_write+0xae/0x137 [ 3256.534257]
[<ffffffff803abdc0>] redirected_tty_write+0x61/0x92 [ 3256.534257]
[<ffffffff802c93f0>] vfs_write+0xae/0x137 [ 3256.534257]
[<ffffffff802c953d>] sys_write+0x47/0x6e [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff80231b73>] __wake_up+0x22/0x50 [ 3256.534257]
[<ffffffff802de6b6>] touch_mnt_namespace+0x2f/0x31 [ 3256.534257]
[<ffffffff802deb45>] commit_tree+0xdf/0xe1 [ 3256.534257]
[<ffffffff802df810>] attach_recursive_mnt+0x176/0x21d [ 3256.534257]
[<ffffffff802df95b>] graft_tree+0xa4/0xcc [ 3256.534257]
[<ffffffff802dfa31>] do_add_mount+0xae/0x117 [ 3256.534257]
[<ffffffff802e0ba3>] do_mount+0x706/0x735 [ 3256.534257]
[<ffffffff802e0c5b>] sys_mount+0x89/0xd6 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802d8c33>] __d_path+0x3d/0x15e [ 3256.534257]
[<ffffffff802d8fa4>] d_path+0xc7/0xee [ 3256.534257]
[<ffffffff8030fa59>] proc_pid_readlink+0x6e/0xc7 [ 3256.534257]
[<ffffffff802cc40b>] sys_readlinkat+0x6b/0x84 [ 3256.534257]
[<ffffffff802cc43a>] sys_readlink+0x16/0x18 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    -> (rename_lock){+.+...} ops: 217
{ [ 3256.534257]       HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d94d4>] d_move_locked+0x32/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d94d4>] d_move_locked+0x32/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d94d4>] d_move_locked+0x32/0x25c
[ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff806763e0>]
rename_lock+0x20/0x80 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff802d94f0>] d_move_locked+0x4e/0x25c
[ 3256.534257]    [<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]    [<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]    [<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]    [<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80268a22>] lock_release_non_nested+0x1bd/0x222
[ 3256.534257]    [<ffffffff80268c87>] lock_release+0x200/0x236
[ 3256.534257]    [<ffffffff8048c4df>] _spin_unlock+0x1e/0x4b
[ 3256.534257]    [<ffffffff802d96d2>] d_move_locked+0x230/0x25c
[ 3256.534257]    [<ffffffff802d9722>] d_move+0x24/0x35
[ 3256.534257]    [<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8
[ 3256.534257]    [<ffffffff802d3937>] sys_renameat+0x186/0x20a
[ 3256.534257]    [<ffffffff802d39d1>] sys_rename+0x16/0x18
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802d94d4>] d_move_locked+0x32/0x25c [ 3256.534257]
[<ffffffff802d9722>] d_move+0x24/0x35 [ 3256.534257]
[<ffffffff802d1da0>] vfs_rename+0x29f/0x3d8 [ 3256.534257]
[<ffffffff802d3937>] sys_renameat+0x186/0x20a [ 3256.534257]
[<ffffffff802d39d1>] sys_rename+0x16/0x18 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    -> (sb_lock){+.+.-.} ops: 6053 { [ 3256.534257]
HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802caa0a>] sget+0x46/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802caa0a>] sget+0x46/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802d8671>] shrink_dcache_memory+0x65/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802caa0a>] sget+0x46/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff806124f8>]
sb_lock+0x18/0x40 [ 3256.534257]     -> (unnamed_dev_ida.lock){......}
ops: 52 { [ 3256.534257]        INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]
[<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]
[<ffffffff802ca331>] set_anon_super+0x25/0xc1
[ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff80612590>]
unnamed_dev_ida+0x30/0x60 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80355955>] idr_pre_get+0x41/0x75
[ 3256.534257]    [<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]    [<ffffffff802ca331>] set_anon_super+0x25/0xc1
[ 3256.534257]    [<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]    [<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]    [<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]    [<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]    [<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]    [<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]    [<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]    [<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]    [<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c [ 3256.534257]
[<ffffffff80355941>] idr_pre_get+0x2d/0x75 [ 3256.534257]
[<ffffffff803559a5>] ida_pre_get+0x1c/0xf7 [ 3256.534257]
[<ffffffff802ca331>] set_anon_super+0x25/0xc1 [ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0 [ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2 [ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18 [ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99 [ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16 [ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8 [ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271 [ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e [ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398 [ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]    [<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c20c5>] kmem_cache_alloc_node+0x112/0x214
[ 3256.534257]    [<ffffffff802c22ce>] cache_grow+0x107/0x3dc
[ 3256.534257]    [<ffffffff802c2859>] cache_alloc_refill+0x2b6/0x305
[ 3256.534257]    [<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c
[ 3256.534257]    [<ffffffff80355941>] idr_pre_get+0x2d/0x75
[ 3256.534257]    [<ffffffff803559a5>] ida_pre_get+0x1c/0xf7
[ 3256.534257]    [<ffffffff802ca331>] set_anon_super+0x25/0xc1
[ 3256.534257]    [<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]    [<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]    [<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]    [<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]    [<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]    [<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]    [<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]    [<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]    [<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     -> (unnamed_dev_lock){+.+...} ops: 18
{ [ 3256.534257]        HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802ca34b>] set_anon_super+0x3f/0xc1
[ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802ca34b>] set_anon_super+0x3f/0xc1
[ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]        INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]
[<ffffffff802ca34b>] set_anon_super+0x3f/0xc1
[ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      }
[ 3256.534257]      ... key      at: [<ffffffff80612538>]
unnamed_dev_lock+0x18/0x40 [ 3256.534257]      ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]    [<ffffffff80355029>] get_from_free_list+0x1c/0x50
[ 3256.534257]    [<ffffffff803550f2>] idr_get_empty_slot+0x2f/0x24d
[ 3256.534257]    [<ffffffff80355353>] ida_get_new_above+0x43/0x1b4
[ 3256.534257]    [<ffffffff803554d2>] ida_get_new+0xe/0x10
[ 3256.534257]    [<ffffffff802ca35a>] set_anon_super+0x4e/0xc1
[ 3256.534257]    [<ffffffff802cadb8>] sget+0x3f4/0x4c0
[ 3256.534257]    [<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]    [<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]    [<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]    [<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]    [<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]    [<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]    [<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]    [<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]    [<ffffffff806842a3>]
x86_64_start_reservations+0xaa/0xae [ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]     ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802ca34b>] set_anon_super+0x3f/0xc1 [ 3256.534257]
[<ffffffff802cadb8>] sget+0x3f4/0x4c0 [ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2 [ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18 [ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99 [ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16 [ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8 [ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271 [ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e [ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398 [ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]    [<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802d8671>] shrink_dcache_memory+0x65/0x193 [ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188 [ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8 [ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    -> (&sem->wait_lock){....-.} ops: 3141613
{ [ 3256.534257]       IN-RECLAIM_FS-W at:
[ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80359678>] __down_read_trylock+0x16/0x46
[ 3256.534257]
[<ffffffff802599a8>] down_read_trylock+0x13/0x4c
[ 3256.534257]
[<ffffffff802d86c5>] shrink_dcache_memory+0xb9/0x193
[ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188
[ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8
[ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83
[ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]       INITIAL
USE at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80359632>] __down_write_trylock+0x16/0x46
[ 3256.534257]
[<ffffffff802598c1>] down_write_nested+0x4e/0x7a
[ 3256.534257]
[<ffffffff802cacf5>] sget+0x331/0x4c0
[ 3256.534257]
[<ffffffff802cb418>] get_sb_single+0x33/0xb2
[ 3256.534257]
[<ffffffff8031c2b4>] sysfs_get_sb+0x16/0x18
[ 3256.534257]
[<ffffffff802ca1cd>] vfs_kern_mount+0x52/0x99
[ 3256.534257]
[<ffffffff802ca228>] kern_mount_data+0x14/0x16
[ 3256.534257]
[<ffffffff806a0d38>] sysfs_init+0x5d/0xb8
[ 3256.534257]
[<ffffffff8069f4a3>] mnt_init+0xa6/0x271
[ 3256.534257]
[<ffffffff8069f0b0>] vfs_caches_init+0x10d/0x11e
[ 3256.534257]
[<ffffffff80684c57>] start_kernel+0x36a/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]     }
[ 3256.534257]     ... key      at: [<ffffffff8116ff98>]
__key.16979+0x0/0x8 [ 3256.534257]     ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff80231c89>] task_rq_lock+0x4c/0x7e
[ 3256.534257]    [<ffffffff80239a94>] try_to_wake_up+0x94/0x307
[ 3256.534257]    [<ffffffff80239d33>] wake_up_process+0x10/0x12
[ 3256.534257]    [<ffffffff8035984d>] __up_write+0xdb/0x124
[ 3256.534257]    [<ffffffff80259a3c>] up_write+0x26/0x2a
[ 3256.534257]    [<ffffffff8020fee0>] sys_mmap+0xae/0xce
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff80359678>] __down_read_trylock+0x16/0x46 [ 3256.534257]
[<ffffffff802599a8>] down_read_trylock+0x13/0x4c [ 3256.534257]
[<ffffffff802d86c5>] shrink_dcache_memory+0xb9/0x193 [ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188 [ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8 [ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802f2efd>] set_dentry_child_flags+0x27/0xdf [ 3256.534257]
[<ffffffff802f30a5>] inotify_add_watch+0xf0/0x111 [ 3256.534257]
[<ffffffff802f3ff2>] sys_inotify_add_watch+0x120/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80297678>] rmqueue_bulk+0x30/0x96 [ 3256.534257]
[<ffffffff8029966e>] get_page_from_freelist+0x343/0x72e
[ 3256.534257]    [<ffffffff80299dd8>]
__alloc_pages_internal+0x101/0x459 [ 3256.534257]
[<ffffffff802c0b07>] kmem_getpages+0x68/0x12e [ 3256.534257]
[<ffffffff802c229d>] cache_grow+0xd6/0x3dc [ 3256.534257]
[<ffffffff802c2859>] cache_alloc_refill+0x2b6/0x305 [ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c [ 3256.534257]
[<ffffffff80355941>] idr_pre_get+0x2d/0x75 [ 3256.534257]
[<ffffffff802f2dca>] inotify_handle_get_wd+0x24/0x65 [ 3256.534257]
[<ffffffff802f3014>] inotify_add_watch+0x5f/0x111 [ 3256.534257]
[<ffffffff802f3ff2>] sys_inotify_add_watch+0x120/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802f2cda>] pin_to_kill+0x36/0x102 [ 3256.534257]
[<ffffffff802f378b>] inotify_destroy+0x76/0xec [ 3256.534257]
[<ffffffff802f3b0c>] inotify_release+0x24/0xe8 [ 3256.534257]
[<ffffffff802c9e01>] __fput+0xeb/0x1a7 [ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802431a5>] put_files_struct+0x6b/0xc2 [ 3256.534257]
[<ffffffff80243243>] exit_files+0x47/0x50 [ 3256.534257]
[<ffffffff802449c5>] do_exit+0x1ff/0x6a6 [ 3256.534257]
[<ffffffff80244eeb>] do_group_exit+0x7f/0xaf [ 3256.534257]
[<ffffffff80244f2d>] sys_exit_group+0x12/0x16 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257] [ 3256.534257]
-> (&dev->ev_mutex){+.+.+.} ops: 221537 { [ 3256.534257]
HARDIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f04>] __lock_acquire+0x7de/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f3ac0>] inotify_poll+0x3c/0x64
[ 3256.534257]
[<ffffffff802d731a>] do_select+0x3e9/0x5da
[ 3256.534257]
[<ffffffff802d7721>] core_sys_select+0x216/0x2e0
[ 3256.534257]
[<ffffffff802d7a21>] sys_select+0x94/0xbc
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
SOFTIRQ-ON-W at:
[ 3256.534257]
[<ffffffff80266f2c>] __lock_acquire+0x806/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f3ac0>] inotify_poll+0x3c/0x64
[ 3256.534257]
[<ffffffff802d731a>] do_select+0x3e9/0x5da
[ 3256.534257]
[<ffffffff802d7721>] core_sys_select+0x216/0x2e0
[ 3256.534257]
[<ffffffff802d7a21>] sys_select+0x94/0xbc
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
RECLAIM_FS-ON-W at:
[ 3256.534257]
[<ffffffff80265707>] mark_held_locks+0x4d/0x6b
[ 3256.534257]
[<ffffffff802657de>] lockdep_trace_alloc+0xb9/0xdb
[ 3256.534257]
[<ffffffff802c35db>] __kmalloc+0x70/0x27c
[ 3256.534257]
[<ffffffff802f43e2>] kernel_event+0xa7/0x10e
[ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]
[<ffffffff802f334a>] inotify_inode_queue_event+0xab/0xe0
[ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]
[<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a
[ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72
[ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]      INITIAL USE
at: [ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362
[ 3256.534257]
[<ffffffff802f3ac0>] inotify_poll+0x3c/0x64
[ 3256.534257]
[<ffffffff802d731a>] do_select+0x3e9/0x5da
[ 3256.534257]
[<ffffffff802d7721>] core_sys_select+0x216/0x2e0
[ 3256.534257]
[<ffffffff802d7a21>] sys_select+0x94/0xbc
[ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]    }
[ 3256.534257]    ... key      at: [<ffffffff8116d298>]
__key.21429+0x0/0x8 [ 3256.534257]    ... acquired at:
[ 3256.534257]    [<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c
[ 3256.534257]    [<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]    [<ffffffff8048c6c0>] _spin_lock+0x3c/0x70
[ 3256.534257]    [<ffffffff802c262c>] cache_alloc_refill+0x89/0x305
[ 3256.534257]    [<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c
[ 3256.534257]    [<ffffffff802f4368>] kernel_event+0x2d/0x10e
[ 3256.534257]    [<ffffffff802f4520>]
inotify_dev_queue_event+0xd7/0x157 [ 3256.534257]
[<ffffffff802f334a>] inotify_inode_queue_event+0xab/0xe0
[ 3256.534257]    [<ffffffff802f3a2b>]
inotify_dentry_parent_queue_event+0x71/0x92 [ 3256.534257]
[<ffffffff802c9d90>] __fput+0x7a/0x1a7 [ 3256.534257]
[<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff80231b73>] __wake_up+0x22/0x50 [ 3256.534257]
[<ffffffff802f4571>] inotify_dev_queue_event+0x128/0x157
[ 3256.534257]    [<ffffffff802f334a>]
inotify_inode_queue_event+0xab/0xe0 [ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]    [<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]    [<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c [ 3256.534257]
[<ffffffff80488f28>] __schedule+0x15b/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80489a39>] preempt_schedule+0x31/0x4f [ 3256.534257]
[<ffffffff8048a8a4>] mutex_lock_nested+0x353/0x362 [ 3256.534257]
[<ffffffff802f3ac0>] inotify_poll+0x3c/0x64 [ 3256.534257]
[<ffffffff802d6b3e>] do_sys_poll+0x220/0x3c7 [ 3256.534257]
[<ffffffff802d6e7a>] sys_poll+0x50/0xba [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff802c262c>] cache_alloc_refill+0x89/0x305 [ 3256.534257]
[<ffffffff802c36f3>] __kmalloc+0x188/0x27c [ 3256.534257]
[<ffffffff802f43e2>] kernel_event+0xa7/0x10e [ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]    [<ffffffff802f334a>]
inotify_inode_queue_event+0xab/0xe0 [ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]    [<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]    [<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]    ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c6c0>] _spin_lock+0x3c/0x70 [ 3256.534257]
[<ffffffff80297678>] rmqueue_bulk+0x30/0x96 [ 3256.534257]
[<ffffffff8029966e>] get_page_from_freelist+0x343/0x72e
[ 3256.534257]    [<ffffffff80299dd8>]
__alloc_pages_internal+0x101/0x459 [ 3256.534257]
[<ffffffff802c0b07>] kmem_getpages+0x68/0x12e [ 3256.534257]
[<ffffffff802c229d>] cache_grow+0xd6/0x3dc [ 3256.534257]
[<ffffffff802c2859>] cache_alloc_refill+0x2b6/0x305 [ 3256.534257]
[<ffffffff802c4539>] kmem_cache_alloc+0x13a/0x23c [ 3256.534257]
[<ffffffff802f4368>] kernel_event+0x2d/0x10e [ 3256.534257]
[<ffffffff802f4520>] inotify_dev_queue_event+0xd7/0x157
[ 3256.534257]    [<ffffffff802f334a>]
inotify_inode_queue_event+0xab/0xe0 [ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]    [<ffffffff802d9c78>] d_delete+0xc6/0xce
[ 3256.534257]    [<ffffffff802d1a68>] vfs_unlink+0xe7/0xfb
[ 3256.534257]    [<ffffffff802d3aa0>] do_unlinkat+0xcd/0x164
[ 3256.534257]    [<ffffffff802d3b48>] sys_unlink+0x11/0x13
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362 [ 3256.534257]
[<ffffffff802f447f>] inotify_dev_queue_event+0x36/0x157
[ 3256.534257]    [<ffffffff802f334a>]
inotify_inode_queue_event+0xab/0xe0 [ 3256.534257]
[<ffffffff802f3a2b>] inotify_dentry_parent_queue_event+0x71/0x92
[ 3256.534257]    [<ffffffff802c9d90>] __fput+0x7a/0x1a7
[ 3256.534257]    [<ffffffff802c9ed5>] fput+0x18/0x1a [ 3256.534257]
[<ffffffff802c7180>] filp_close+0x67/0x72 [ 3256.534257]
[<ffffffff802c7230>] sys_close+0xa5/0xe4 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]   ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c [ 3256.534257]
[<ffffffff80488f28>] __schedule+0x15b/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80489a39>] preempt_schedule+0x31/0x4f [ 3256.534257]
[<ffffffff8048a8a4>] mutex_lock_nested+0x353/0x362 [ 3256.534257]
[<ffffffff802f311d>] inotify_find_update_watch+0x57/0xca
[ 3256.534257]    [<ffffffff802f406f>]
sys_inotify_add_watch+0x19d/0x1a9 [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]
[ 3256.534257]  ... acquired at: [ 3256.534257]    [<ffffffff80267b13>]
__lock_acquire+0x13ed/0x177c [ 3256.534257]    [<ffffffff80267fa6>]
lock_acquire+0x104/0x130 [ 3256.534257]    [<ffffffff8048a5bb>]
mutex_lock_nested+0x6a/0x362 [ 3256.534257]    [<ffffffff802f311d>]
inotify_find_update_watch+0x57/0xca [ 3256.534257]
[<ffffffff802f406f>] sys_inotify_add_watch+0x19d/0x1a9
[ 3256.534257]    [<ffffffff8020b142>] system_call_fastpath+0x16/0x1b
[ 3256.534257]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 3256.534257] [ 3256.534257]  ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c7b2>] _spin_lock_irq+0x48/0x7c [ 3256.534257]
[<ffffffff80488f28>] __schedule+0x15b/0xa17 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80489a39>] preempt_schedule+0x31/0x4f [ 3256.534257]
[<ffffffff8048a8a4>] mutex_lock_nested+0x353/0x362 [ 3256.534257]
[<ffffffff802f32ee>] inotify_inode_queue_event+0x4f/0xe0
[ 3256.534257]    [<ffffffff802f3a2b>]
inotify_dentry_parent_queue_event+0x71/0x92 [ 3256.534257]
[<ffffffff802c9671>] vfs_read+0x10d/0x134 [ 3256.534257]
[<ffffffff802c975c>] sys_read+0x47/0x6f [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257] [ 3256.534257]
-> (pgd_lock){......} ops: 11776 { [ 3256.534257]     INITIAL USE at:
[ 3256.534257]
[<ffffffff80266f95>] __lock_acquire+0x86f/0x177c
[ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130
[ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c
[ 3256.534257]
[<ffffffff80228b66>] update_page_count+0x1b/0x37
[ 3256.534257]
[<ffffffff806b3720>] phys_pte_init+0x126/0x138
[ 3256.534257]
[<ffffffff806b38f8>] phys_pmd_init+0x1c6/0x26f
[ 3256.534257]
[<ffffffff806b3ab1>] phys_pud_init+0x110/0x2a9
[ 3256.534257]
[<ffffffff806951d3>] kernel_physical_mapping_init+0xc9/0x1ad
[ 3256.534257]
[<ffffffff8047851f>] init_memory_mapping+0x389/0x412
[ 3256.534257]
[<ffffffff8068713b>] setup_arch+0x475/0x688
[ 3256.534257]
[<ffffffff80684983>] start_kernel+0x96/0x398
[ 3256.534257]
[<ffffffff806842a3>] x86_64_start_reservations+0xaa/0xae
[ 3256.534257]
[<ffffffff8068439e>] x86_64_start_kernel+0xf7/0x106
[ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257]   }
[ 3256.534257]   ... key      at: [<ffffffff80606ae8>]
pgd_lock+0x18/0x40 [ 3256.534257]  ... acquired at: [ 3256.534257]
[<ffffffff80267b13>] __lock_acquire+0x13ed/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff8048c83a>] _spin_lock_irqsave+0x54/0x8c [ 3256.534257]
[<ffffffff8022b718>] pgd_free+0x1f/0x8f [ 3256.534257]
[<ffffffff8023f174>] __mmdrop+0x22/0x3e [ 3256.534257]
[<ffffffff802377de>] finish_task_switch+0xb3/0xdc [ 3256.534257]
[<ffffffff8048982d>] thread_return+0x49/0xb6 [ 3256.534257]
[<ffffffff804898ad>] schedule+0x13/0x31 [ 3256.534257]
[<ffffffff80489a39>] preempt_schedule+0x31/0x4f [ 3256.534257]
[<ffffffff8048a8a4>] mutex_lock_nested+0x353/0x362 [ 3256.534257]
[<ffffffff802f32ee>] inotify_inode_queue_event+0x4f/0xe0
[ 3256.534257]    [<ffffffff802f3a2b>]
inotify_dentry_parent_queue_event+0x71/0x92 [ 3256.534257]
[<ffffffff802c9671>] vfs_read+0x10d/0x134 [ 3256.534257]
[<ffffffff802c975c>] sys_read+0x47/0x6f [ 3256.534257]
[<ffffffff8020b142>] system_call_fastpath+0x16/0x1b [ 3256.534257]
[<ffffffffffffffff>] 0xffffffffffffffff [ 3256.534257] [ 3256.534257]
[ 3256.534257] stack backtrace: [ 3256.534257] Pid: 449, comm: kswapd0
Tainted: G        W  2.6.30-rc2 #94 [ 3256.534257] Call Trace:
[ 3256.534257]  [<ffffffff80265df1>]
print_irq_inversion_bug+0x182/0x193 [ 3256.534257]
[<ffffffff80265e02>] ? check_usage_forwards+0x0/0xa0 [ 3256.534257]
[<ffffffff80265e9a>] check_usage_forwards+0x98/0xa0 [ 3256.534257]
[<ffffffff80265480>] mark_lock+0x334/0x56e [ 3256.534257]
[<ffffffff80266f79>] __lock_acquire+0x853/0x177c [ 3256.534257]
[<ffffffff80267e89>] ? __lock_acquire+0x1763/0x177c [ 3256.534257]
[<ffffffff80267fa6>] lock_acquire+0x104/0x130 [ 3256.534257]
[<ffffffff802db9e7>] ? shrink_icache_memory+0x45/0x255 [ 3256.534257]
[<ffffffff8048a5bb>] mutex_lock_nested+0x6a/0x362 [ 3256.534257]
[<ffffffff802db9e7>] ? shrink_icache_memory+0x45/0x255 [ 3256.534257]
[<ffffffff80263df8>] ? put_lock_stats+0xe/0x27 [ 3256.534257]
[<ffffffff802db9e7>] ? shrink_icache_memory+0x45/0x255 [ 3256.534257]
[<ffffffff802db9e7>] shrink_icache_memory+0x45/0x255 [ 3256.534257]
[<ffffffff8029fd34>] shrink_slab+0xdf/0x188 [ 3256.534257]
[<ffffffff802a0579>] kswapd+0x4f2/0x6a8 [ 3256.534257]
[<ffffffff8029db81>] ? isolate_pages_global+0x0/0x224 [ 3256.534257]
[<ffffffff80256344>] ? autoremove_wake_function+0x0/0x38
[ 3256.534257]  [<ffffffff802a0087>] ? kswapd+0x0/0x6a8 [ 3256.534257]
[<ffffffff80255f21>] kthread+0x56/0x83 [ 3256.534257]
[<ffffffff8020c27a>] child_rip+0xa/0x20 [ 3256.534257]
[<ffffffff802377aa>] ? finish_task_switch+0x7f/0xdc [ 3256.534257]
[<ffffffff8048c430>] ? _spin_unlock_irq+0x3c/0x57 [ 3256.534257]
[<ffffffff8020bc14>] ? restore_args+0x0/0x30 [ 3256.534257]
[<ffffffff80488f28>] ? __schedule+0x15b/0xa17 [ 3256.534257]
[<ffffffff80255ecb>] ? kthread+0x0/0x83 [ 3256.534257]
[<ffffffff8020c270>] ? child_rip+0x0/0x20

-- 
Lei Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
