Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 602ACC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:18:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0460920872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:18:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0460920872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88F2D6B0007; Tue, 10 Sep 2019 03:18:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83D366B0008; Tue, 10 Sep 2019 03:18:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72B106B000A; Tue, 10 Sep 2019 03:18:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1C06B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 03:18:21 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D71BB180AD802
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:18:20 +0000 (UTC)
X-FDA: 75918157560.08.blade44_82dc899993347
X-HE-Tag: blade44_82dc899993347
X-Filterd-Recvd-Size: 8122
Received: from r3-24.sinamail.sina.com.cn (r3-24.sinamail.sina.com.cn [202.108.3.24])
	by imf20.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:18:18 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([61.148.244.178])
	by sina.com with ESMTP
	id 5D774E360001D9DF; Tue, 10 Sep 2019 15:18:16 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 54868954920922
From: Hillf Danton <hdanton@sina.com>
To: syzbot <syzbot+5d04068d02b9da8a0947@syzkaller.appspotmail.com>
Cc: hughd@google.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	syzkaller-bugs@googlegroups.com,
	Peter Zijlstra <peterz@infradead.org>,
	Omar Sandoval <osandov@fb.com>
Subject: Re: possible deadlock in shmem_fallocate (3)
Date: Tue, 10 Sep 2019 15:18:04 +0800
Message-Id: <20190910071804.2944-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> syzbot found the following crash on Mon, 09 Sep 2019 20:38:05 -0700
>=20
> HEAD commit:    6d028043 Add linux-next specific files for 20190830
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=3D12359ec6600=
000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=3D82a6bec43ab=
0cb69
> dashboard link: https://syzkaller.appspot.com/bug?extid=3D5d04068d02b9d=
a8a0947
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
>=20
> Unfortunately, I don't have any reproducer for this crash yet.
>=20
> IMPORTANT: if you fix the bug, please add the following tag to the comm=
it:
> Reported-by: syzbot+5d04068d02b9da8a0947@syzkaller.appspotmail.com
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> WARNING: possible circular locking dependency detected
> 5.3.0-rc6-next-20190830 #75 Not tainted
> ------------------------------------------------------
> kswapd0/1770 is trying to acquire lock:
> ffff8880a0b9b780 (&sb->s_type->i_mutex_key#13){+.+.}, at: inode_lock =20
> include/linux/fs.h:789 [inline]
> ffff8880a0b9b780 (&sb->s_type->i_mutex_key#13){+.+.}, at: =20
> shmem_fallocate+0x15a/0xc60 mm/shmem.c:2728
>=20
> but task is already holding lock:
> ffffffff89042f80 (fs_reclaim){+.+.}, at: __fs_reclaim_acquire+0x0/0x30 =
=20
> mm/page_alloc.c:4889
>=20
> which lock already depends on the new lock.
>=20
>=20
> the existing dependency chain (in reverse order) is:
>=20
> -> #1 (fs_reclaim){+.+.}:
>         __fs_reclaim_acquire mm/page_alloc.c:4075 [inline]
>         fs_reclaim_acquire.part.0+0x24/0x30 mm/page_alloc.c:4086
>         fs_reclaim_acquire mm/page_alloc.c:4662 [inline]
>         prepare_alloc_pages mm/page_alloc.c:4659 [inline]
>         __alloc_pages_nodemask+0x52f/0x900 mm/page_alloc.c:4711
>         alloc_pages_vma+0x1bc/0x3f0 mm/mempolicy.c:2114
>         shmem_alloc_page+0xbd/0x180 mm/shmem.c:1496
>         shmem_alloc_and_acct_page+0x165/0x990 mm/shmem.c:1521
>         shmem_getpage_gfp+0x598/0x2680 mm/shmem.c:1835
>         shmem_getpage mm/shmem.c:152 [inline]
>         shmem_write_begin+0x105/0x1e0 mm/shmem.c:2480
>         generic_perform_write+0x23b/0x540 mm/filemap.c:3304
>         __generic_file_write_iter+0x25e/0x630 mm/filemap.c:3433
>         generic_file_write_iter+0x420/0x690 mm/filemap.c:3465
>         call_write_iter include/linux/fs.h:1890 [inline]
>         new_sync_write+0x4d3/0x770 fs/read_write.c:483
>         __vfs_write+0xe1/0x110 fs/read_write.c:496
>         vfs_write+0x268/0x5d0 fs/read_write.c:558
>         ksys_write+0x14f/0x290 fs/read_write.c:611
>         __do_sys_write fs/read_write.c:623 [inline]
>         __se_sys_write fs/read_write.c:620 [inline]
>         __x64_sys_write+0x73/0xb0 fs/read_write.c:620
>         do_syscall_64+0xfa/0x760 arch/x86/entry/common.c:290
>         entry_SYSCALL_64_after_hwframe+0x49/0xbe
>=20
> -> #0 (&sb->s_type->i_mutex_key#13){+.+.}:
>         check_prev_add kernel/locking/lockdep.c:2476 [inline]
>         check_prevs_add kernel/locking/lockdep.c:2581 [inline]
>         validate_chain kernel/locking/lockdep.c:2971 [inline]
>         __lock_acquire+0x2596/0x4a00 kernel/locking/lockdep.c:3955
>         lock_acquire+0x190/0x410 kernel/locking/lockdep.c:4487
>         down_write+0x93/0x150 kernel/locking/rwsem.c:1534
>         inode_lock include/linux/fs.h:789 [inline]
>         shmem_fallocate+0x15a/0xc60 mm/shmem.c:2728
>         ashmem_shrink_scan drivers/staging/android/ashmem.c:462 [inline=
]
>         ashmem_shrink_scan+0x370/0x510 drivers/staging/android/ashmem.c=
:437
>         do_shrink_slab+0x40f/0xa30 mm/vmscan.c:560
>         shrink_slab mm/vmscan.c:721 [inline]
>         shrink_slab+0x19a/0x680 mm/vmscan.c:694
>         shrink_node+0x223/0x12e0 mm/vmscan.c:2807
>         kswapd_shrink_node mm/vmscan.c:3549 [inline]
>         balance_pgdat+0x57c/0xea0 mm/vmscan.c:3707
>         kswapd+0x5c3/0xf30 mm/vmscan.c:3958
>         kthread+0x361/0x430 kernel/kthread.c:255
>         ret_from_fork+0x24/0x30 arch/x86/entry/entry_64.S:352
>=20
> other info that might help us debug this:
>=20
>   Possible unsafe locking scenario:
>=20
>         CPU0                    CPU1
>         ----                    ----
>    lock(fs_reclaim);
>                                 lock(&sb->s_type->i_mutex_key#13);
>                                 lock(fs_reclaim);
>    lock(&sb->s_type->i_mutex_key#13);
>=20
>   *** DEADLOCK ***
>=20
> 2 locks held by kswapd0/1770:
>   #0: ffffffff89042f80 (fs_reclaim){+.+.}, at: __fs_reclaim_acquire+0x0=
/0x30 =20
> mm/page_alloc.c:4889
>   #1: ffffffff8901ffe8 (shrinker_rwsem){++++}, at: shrink_slab =20
> mm/vmscan.c:711 [inline]
>   #1: ffffffff8901ffe8 (shrinker_rwsem){++++}, at: shrink_slab+0xe6/0x6=
80 =20
> mm/vmscan.c:694
>=20
> stack backtrace:
> CPU: 0 PID: 1770 Comm: kswapd0 Not tainted 5.3.0-rc6-next-20190830 #75
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS=
 =20
> Google 01/01/2011
> Call Trace:
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
>   print_circular_bug.isra.0.cold+0x163/0x172 kernel/locking/lockdep.c:1=
685
>   check_noncircular+0x32e/0x3e0 kernel/locking/lockdep.c:1809
>   check_prev_add kernel/locking/lockdep.c:2476 [inline]
>   check_prevs_add kernel/locking/lockdep.c:2581 [inline]
>   validate_chain kernel/locking/lockdep.c:2971 [inline]
>   __lock_acquire+0x2596/0x4a00 kernel/locking/lockdep.c:3955
>   lock_acquire+0x190/0x410 kernel/locking/lockdep.c:4487
>   down_write+0x93/0x150 kernel/locking/rwsem.c:1534
>   inode_lock include/linux/fs.h:789 [inline]
>   shmem_fallocate+0x15a/0xc60 mm/shmem.c:2728
>   ashmem_shrink_scan drivers/staging/android/ashmem.c:462 [inline]
>   ashmem_shrink_scan+0x370/0x510 drivers/staging/android/ashmem.c:437
>   do_shrink_slab+0x40f/0xa30 mm/vmscan.c:560
>   shrink_slab mm/vmscan.c:721 [inline]
>   shrink_slab+0x19a/0x680 mm/vmscan.c:694
>   shrink_node+0x223/0x12e0 mm/vmscan.c:2807
>   kswapd_shrink_node mm/vmscan.c:3549 [inline]
>   balance_pgdat+0x57c/0xea0 mm/vmscan.c:3707
>   kswapd+0x5c3/0xf30 mm/vmscan.c:3958
>   kthread+0x361/0x430 kernel/kthread.c:255
>   ret_from_fork+0x24/0x30 arch/x86/entry/entry_64.S:352

It burns more than pure cpu cycles to check anything against kswapd
in terms of __GFP_FS, so fix 93781325da6e and d92a8cfcb37e.


--- works/jj/vmscan.c	2019-09-10 14:52:00.602771300 +0800
+++ works/zz/vmscan.c	2019-09-10 14:54:48.101915500 +0800
@@ -3593,7 +3593,6 @@ static int balance_pgdat(pg_data_t *pgda
=20
 	set_task_reclaim_state(current, &sc.reclaim_state);
 	psi_memstall_enter(&pflags);
-	__fs_reclaim_acquire();
=20
 	count_vm_event(PAGEOUTRUN);
=20
@@ -3718,9 +3717,7 @@ restart:
 			wake_up_all(&pgdat->pfmemalloc_wait);
=20
 		/* Check if kswapd should be suspending */
-		__fs_reclaim_release();
 		ret =3D try_to_freeze();
-		__fs_reclaim_acquire();
 		if (ret || kthread_should_stop())
 			break;
=20
@@ -3770,7 +3767,6 @@ out:
 	}
=20
 	snapshot_refaults(NULL, pgdat);
-	__fs_reclaim_release();
 	psi_memstall_leave(&pflags);
 	set_task_reclaim_state(current, NULL);
=20
--


