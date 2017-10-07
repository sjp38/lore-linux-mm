Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 592856B025E
	for <linux-mm@kvack.org>; Sat,  7 Oct 2017 05:23:01 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d10so3039406lfg.4
        for <linux-mm@kvack.org>; Sat, 07 Oct 2017 02:23:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o80sor521590lfb.102.2017.10.07.02.22.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Oct 2017 02:22:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
References: <CABXGCsOL+_OgC0dpO1+Zeg=iu7ryZRZT4S7k-io8EGB0ZRgZGw@mail.gmail.com>
 <20170903074306.GA8351@infradead.org> <CABXGCsMmEvEh__R2L47jqVnxv9XDaT_KP67jzsUeDLhF2OuOyA@mail.gmail.com>
 <20170904123039.GA5664@quack2.suse.cz> <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
From: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Date: Sat, 7 Oct 2017 14:22:42 +0500
Message-ID: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

And yet another

[41288.797026] INFO: task tracker-store:4535 blocked for more than 120 seconds.
[41288.797034]       Not tainted 4.13.4-301.fc27.x86_64+debug #1
[41288.797037] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[41288.797041] tracker-store   D10616  4535   1655 0x00000000
[41288.797049] Call Trace:
[41288.797061]  __schedule+0x2dc/0xbb0
[41288.797072]  ? bit_wait+0x60/0x60
[41288.797076]  schedule+0x3d/0x90
[41288.797082]  io_schedule+0x16/0x40
[41288.797086]  bit_wait_io+0x11/0x60
[41288.797091]  __wait_on_bit+0x31/0x90
[41288.797099]  out_of_line_wait_on_bit+0x94/0xb0
[41288.797106]  ? bit_waitqueue+0x40/0x40
[41288.797113]  __block_write_begin_int+0x265/0x550
[41288.797132]  iomap_write_begin.constprop.14+0x7d/0x130
[41288.797140]  iomap_write_actor+0x92/0x180
[41288.797152]  ? iomap_write_begin.constprop.14+0x130/0x130
[41288.797155]  iomap_apply+0x9f/0x110
[41288.797165]  ? iomap_write_begin.constprop.14+0x130/0x130
[41288.797169]  iomap_file_buffered_write+0x6e/0xa0
[41288.797171]  ? iomap_write_begin.constprop.14+0x130/0x130
[41288.797212]  xfs_file_buffered_aio_write+0xdd/0x380 [xfs]
[41288.797250]  xfs_file_write_iter+0x9e/0x140 [xfs]
[41288.797258]  __vfs_write+0xf8/0x170
[41288.797270]  vfs_write+0xc6/0x1c0
[41288.797275]  SyS_pwrite64+0x98/0xc0
[41288.797284]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[41288.797287] RIP: 0033:0x7f357aa30163
[41288.797289] RSP: 002b:00007ffe6bef2070 EFLAGS: 00000293 ORIG_RAX:
0000000000000012
[41288.797292] RAX: ffffffffffffffda RBX: 00000000000027f7 RCX: 00007f357aa30163
[41288.797294] RDX: 0000000000001000 RSI: 0000559141745d18 RDI: 0000000000000009
[41288.797296] RBP: 0000000000010351 R08: 0000559140da78a8 R09: 000055914100c548
[41288.797298] R10: 0000000000743d90 R11: 0000000000000293 R12: 0000000000002c5e
[41288.797299] R13: 000000000000162f R14: 0000559140da77f8 R15: 0000000000000001
[41288.797329]
               Showing all locks held in the system:
[41288.797338] 1 lock held by khungtaskd/65:
[41288.797341]  #0:  (tasklist_lock){.+.+..}, at: [<ffffffff9a114c6d>]
debug_show_all_locks+0x3d/0x1a0
[41288.797358] 1 lock held by kworker/0:1H/377:
[41288.797359]  #0:  (&rq->lock){-.-.-.}, at: [<ffffffff9a9a2af1>]
__schedule+0xe1/0xbb0
[41288.797452] 5 locks held by TaskSchedulerFo/6821:
[41288.797454]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2ccaef>]
do_sys_ftruncate.constprop.17+0xdf/0x110
[41288.797467]  #1:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffff9a2cc795>] do_truncate+0x65/0xc0
[41288.797480]  #2:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at:
[<ffffffffc0a9aef9>] xfs_ilock+0x159/0x220 [xfs]
[41288.797518]  #3:  (sb_internal#2){.+.+.?}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[41288.797548]  #4:  (&xfs_nondir_ilock_class){++++--}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[41288.797610] 2 locks held by TaskSchedulerBa/7167:
[41288.797611]  #0:  (sb_internal#2){.+.+.?}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[41288.797646]  #1:  (&xfs_nondir_ilock_class){++++--}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[41288.797677] 2 locks held by TaskSchedulerFo/7174:
[41288.797678]  #0:  (sb_internal#2){.+.+.?}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[41288.797708]  #1:  (&xfs_nondir_ilock_class){++++--}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[41288.797899] 2 locks held by TaskSchedulerFo/5547:
[41288.797901]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2fa7d4>]
mnt_want_write+0x24/0x50
[41288.797913]  #1:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2e190a>] path_openat+0x30a/0xc80
[41288.797922] 1 lock held by TaskSchedulerFo/5605:
[41288.797923]  #0:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2dcff5>] lookup_slow+0xe5/0x220
[41288.797931] 1 lock held by TaskSchedulerFo/6638:
[41288.797932]  #0:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2dcff5>] lookup_slow+0xe5/0x220
[41288.797940] 1 lock held by TaskSchedulerFo/6830:
[41288.797941]  #0:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2dcff5>] lookup_slow+0xe5/0x220
[41288.797948] 4 locks held by TaskSchedulerFo/6832:
[41288.797949]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2fa7d4>]
mnt_want_write+0x24/0x50
[41288.797957]  #1:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2e190a>] path_openat+0x30a/0xc80
[41288.797964]  #2:  (sb_internal#2){.+.+.?}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[41288.797998]  #3:  (&xfs_dir_ilock_class/5){+.+...}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[41288.798027] 5 locks held by TaskSchedulerFo/6959:
[41288.798028]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2ccaef>]
do_sys_ftruncate.constprop.17+0xdf/0x110
[41288.798035]  #1:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffff9a2cc795>] do_truncate+0x65/0xc0
[41288.798042]  #2:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at:
[<ffffffffc0a9aef9>] xfs_ilock+0x159/0x220 [xfs]
[41288.798064]  #3:  (sb_internal#2){.+.+.?}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[41288.798087]  #4:  (&xfs_nondir_ilock_class){++++--}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[41288.798110] 8 locks held by TaskSchedulerBa/7193:
[41288.798111]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2fa7d4>]
mnt_want_write+0x24/0x50
[41288.798118]  #1:  (&type->i_mutex_dir_key#7/1){+.+.+.}, at:
[<ffffffff9a2dc68a>] lock_rename+0xda/0x100
[41288.798132]  #2:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffff9a2f293d>] lock_two_nondirectories+0x6d/0x80
[41288.798145]  #3:  (&sb->s_type->i_mutex_key#19/4){+.+.+.}, at:
[<ffffffff9a2f2926>] lock_two_nondirectories+0x56/0x80
[41288.798168]  #4:  (sb_internal#2){.+.+.?}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[41288.798203]  #5:  (&xfs_dir_ilock_class){++++-.}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[41288.798230]  #6:  (&xfs_nondir_ilock_class){++++--}, at:
[<ffffffffc0a9b1d7>] xfs_ilock_nowait+0x197/0x270 [xfs]
[41288.798262]  #7:  (&xfs_nondir_ilock_class){++++--}, at:
[<ffffffffc0a9b1d7>] xfs_ilock_nowait+0x197/0x270 [xfs]
[41288.798298] 2 locks held by TaskSchedulerFo/7212:
[41288.798300]  #0:  (sb_internal#2){.+.+.?}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[41288.798332]  #1:  (&xfs_nondir_ilock_class){++++--}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[41288.798360] 1 lock held by TaskSchedulerFo/7297:
[41288.798362]  #0:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2dcff5>] lookup_slow+0xe5/0x220
[41288.798375] 1 lock held by chrome/8645:
[41288.798376]  #0:  (&dev->struct_mutex){+.+.+.}, at:
[<ffffffffc029b8a1>] i915_gem_close_object+0x31/0x130 [i915]
[41288.798619] 3 locks held by kworker/2:3/540:
[41288.798621]  #0:  ("events"){.+.+.+}, at: [<ffffffff9a0d2ac0>]
process_one_work+0x1d0/0x6a0
[41288.798632]  #1:  ((&dev_priv->mm.free_work)){+.+...}, at:
[<ffffffff9a0d2ac0>] process_one_work+0x1d0/0x6a0
[41288.798642]  #2:  (&dev->struct_mutex){+.+.+.}, at:
[<ffffffffc0298515>] __i915_gem_free_objects+0x35/0x420 [i915]
[41288.798680] 2 locks held by tracker-store/4535:
[41288.798682]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2cf953>]
vfs_write+0x193/0x1c0
[41288.798695]  #1:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffffc0a9aedb>] xfs_ilock+0x13b/0x220 [xfs]
[41288.798740] 1 lock held by gitkraken/5915:
[41288.798742]  #0:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2dcff5>] lookup_slow+0xe5/0x220
[41288.798755] 1 lock held by gitkraken/6017:
[41288.798756]  #0:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2dcff5>] lookup_slow+0xe5/0x220
[41288.798768] 1 lock held by gitkraken/6125:
[41288.798770]  #0:  (&type->i_mutex_dir_key#7){++++++}, at:
[<ffffffff9a2dcff5>] lookup_slow+0xe5/0x220

[41288.798788] =============================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
