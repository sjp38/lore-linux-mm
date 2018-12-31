Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF8B4C43387
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 06:31:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7656B20B1F
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 06:31:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LYXMn4nz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7656B20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C2A58E007B; Mon, 31 Dec 2018 01:31:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 070C78E005B; Mon, 31 Dec 2018 01:31:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7B928E007B; Mon, 31 Dec 2018 01:31:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id BCEFA8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 01:31:28 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id x2so30707696ioa.23
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 22:31:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yT+tsqBctM7vCiYLh3mcOtrpbxMPManNTH74WEzE148=;
        b=TTzdHf9Jd+Gz1ye2tCbDCnl1DTHfZRDO2cSc+ultocdLODx+wg4qDe5+Zb6/DQHTnU
         2wJ6lQ7roI26ULTv3wCG/krqM+lS0hR2oEUNOoPb+CcnhVCD/+240hnRI9q3tndU84yP
         4tHMiZ3eYMTa8QGbq6mNxTNNKRzU3M6BtHFKiH9OK11hpWGG6CRszOlsZskiwyvH8/Yh
         fVg5vEP4QQL9KzUl3vbN/Q6ZmK9zcMmbq22i4jAufgT15Utlp1ntqTSm0FM3R8rEEoZe
         uwJ1cqEdTJNKsHLiOvkMCsrdaZJ+dlnsmJsHsuVmy/foxkS/uaS2vcUAL+i/l0jLl/f6
         DTSQ==
X-Gm-Message-State: AJcUukfgXx059CKD+gvib5guw9G8RkvJjtpG07raMrZ/7r2dQconxQje
	09lyIB4X6O6IG/Nydcqz6VhzyE2BPRMOz8gl0QSAHsSM17vXGRO6rWA9H/gTQGbmMh9cKA6f3lE
	mKuJgU9rDhwCB6Q3+Z5WCAX41WDfREikbdYd77CCf/y2L6MD/yL8I1gRe+4P68MZUeZ6PkY0I6a
	RG+jaE12d+R2ozNNAqPEdyRxUAZpc1Mz7SI1WMuspHtVDTb1P1JYfVFJGwYHwgZnUmNHaSo1nId
	27iUMEaC1eYUMuaN5mAZE2+M8nrddpj/ea/CS2qOLiqDfxfg0USPLL3U3ssmL4bWqk0M9M5vsqs
	RS1ztt5cmjlPmPeowG3iKrl/qLM3Qem2H5wQ3SrqCH+eIZwfet7nm0M3insPXVlHn3QTnnhNBvV
	c
X-Received: by 2002:a5e:9e4a:: with SMTP id j10mr10327501ioq.165.1546237888438;
        Sun, 30 Dec 2018 22:31:28 -0800 (PST)
X-Received: by 2002:a5e:9e4a:: with SMTP id j10mr10327466ioq.165.1546237887510;
        Sun, 30 Dec 2018 22:31:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546237887; cv=none;
        d=google.com; s=arc-20160816;
        b=jEv0F+ZpG0hT9KoaUeaD1IBgZWMIk+cEw9xY1XAP46qOGUKE+6V9UxI1KEP5BrZbt2
         CcP3skJH7kNhBtDljuN/kpjn4n6gzQAZ0Wc4jW5wSIyLyvJO3aQ57kojZ1vpqa/r0L/E
         vmtNR2L5UvEQjxx/11ybhNoOpDAMVuUIEwJ3bBq0/6UaZE5bIKFRt0dO3ZZfT7aWbTC8
         IhADhIHFBuTwZ4ZqdPpab3QIiYvv53on9p28FPHZUGpjYgmiWlPNNxyP/LoNtf7ytkk2
         6/MlVUkBqY6gwGkICq+d16U78xsik9G0kbs1yCsKmOKkzkQP+dySk2qR3by2eEty5ynL
         4u4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yT+tsqBctM7vCiYLh3mcOtrpbxMPManNTH74WEzE148=;
        b=d203OXR78m3hpooD2IVOVVg6/QY+wN27ybWQr9RzbsggiKEKtNur1C+34iD9pIMbwF
         6zDw7VMVoJTbRCB9Qs9GLtUaykULDeUIvKQceL1A1Ksvnb8UbiDPjmpkamoDeU5YdVm4
         7HCsqXt4iHRzURzoe0cnRr8Im09t4nRwc0tHf8Pvi+YucPetVgMKDFt03JAsQSY7erD5
         R+4474XULzEvCiKdEsEKBfhKWQiqZHxPvxujSQgd/jUGbwrbZ1/49DZoov1gzXw1VVHn
         3cVxY9hyDswUgluTd2bwcKj/tVcq5W8D2N0EuNnpoGy39c4ih6TSGUFhsziw3w6xIZpA
         Ux3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LYXMn4nz;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor291876ioh.0.2018.12.30.22.31.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 22:31:27 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LYXMn4nz;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yT+tsqBctM7vCiYLh3mcOtrpbxMPManNTH74WEzE148=;
        b=LYXMn4nz+lvDh/icutGeVJV5+eniIw9pXAb7Dv3ufhOW/yO54BGB8o2LSSTAwKxRMZ
         Q7ZiQgX9CQ5lPlZEgYDZKX8oR+xJa01GNMrl2EeVt/nATK9+Ge5a2jv56SoiAzCyZNMU
         hmi+TvCJ6zwiFdii0w6DzYjo7Oqz20/MhM1/hXuVGGAyvMT7uVRG6FpUof+/n0RF7S4d
         292D2+K6+7EePFefkI8cciyrbQA+ydAcgL6dqbGANbilZZw3pbNR94KIorS445nfPYdR
         h3gxCJ0vjoKx+TyI+zx1bBDzIiBF8vWjzPhF+y42VqA5B7BH3dAWnxCw9oRrKAxCWY+e
         tslg==
X-Google-Smtp-Source: ALg8bN5wYys6/A0JTLwtF0KkhpoeNi9Jbukq4jt5Gki90McxNxDWIUdPmilN3vK+EM99t9jvFSRkuXQ19UkgDJKByDQ=
X-Received: by 2002:a5d:8491:: with SMTP id t17mr25091347iom.11.1546237886942;
 Sun, 30 Dec 2018 22:31:26 -0800 (PST)
MIME-Version: 1.0
References: <000000000000b05d0c057e492e33@google.com> <9fe14b68-5a3c-5964-62b1-53a4ef4c0b76@lca.pw>
In-Reply-To: <9fe14b68-5a3c-5964-62b1-53a4ef4c0b76@lca.pw>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 07:31:15 +0100
Message-ID:
 <CACT4Y+Y-WW-giKkihkMXkKxQ2mK7Lhc60fCta3TqssiWGM8-2A@mail.gmail.com>
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: Qian Cai <cai@lca.pw>
Cc: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, guro@fb.com, 
	Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <jbacik@fb.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, 
	Shakeel Butt <shakeelb@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181231063115.3WLpbcRtsYxmZF2f7oN47xhcboXCGbcSoQkDTq7_5iQ@z>

On Mon, Dec 31, 2018 at 4:47 AM Qian Cai <cai@lca.pw> wrote:
>
> Ah, it has KASAN_EXTRA. Need this patch then.
>
> https://lore.kernel.org/lkml/20181228020639.80425-1-cai@lca.pw/
>
> or to use GCC from the HEAD which suppose to reduce the stack-size in half.
>
> shrink_page_list
> shrink_inactive_list
>
> Those things are 7k each, so 32k would be soon gone.

I am not sure it's just KASAN. I reproduced stack overflow at this
stack without KASAN:
https://groups.google.com/forum/#!msg/syzkaller-bugs/ZaBzAJbn6i8/Py9FVlAqDQAJ

Note: this was originally reported 5 months ago:
https://groups.google.com/forum/#!msg/syzkaller-bugs/C7d0Hm6YcDM/nQeciKgtCgAJ
so now at least in 2 releases and causes stream of induced crashes
that people spent time debugging:
https://groups.google.com/forum/#!msg/syzkaller-bugs/ZaBzAJbn6i8/Py9FVlAqDQAJ
https://groups.google.com/forum/#!msg/syzkaller-bugs/GIpnqHiIEQg/5jzwQqqfCwAJ
https://syzkaller.appspot.com/bug?id=26c906d472ea470c2cb58c77f08f964f347cbc68
https://groups.google.com/forum/#!msg/syzkaller-bugs/Ovkbsq5qd84/FHsTYlsfDAAJ
most likely more of these:
https://syzkaller.appspot.com#upstream



> On 12/30/18 10:41 PM, syzbot wrote:
> > Hello,
> >
> > syzbot found the following crash on:
> >
> > HEAD commit:    195303136f19 Merge tag 'kconfig-v4.21-2' of git://git.kern..
> > git tree:       upstream
> > console output: https://syzkaller.appspot.com/x/log.txt?x=176c0ebf400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=5e7dc790609552d7
> > dashboard link: https://syzkaller.appspot.com/bug?extid=ec1b7575afef85a0e5ca
> > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16a9a84b400000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17199bb3400000
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com
> >
> > Kernel panic - not syncing: corrupted stack end detected inside scheduler
> > CPU: 0 PID: 7 Comm: kworker/u4:0 Not tainted 4.20.0+ #396
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google
> > 01/01/2011
> > Workqueue: writeback wb_workfn (flush-8:0)
> > Call Trace:
> >  __dump_stack lib/dump_stack.c:77 [inline]
> >  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
> >  panic+0x2ad/0x55f kernel/panic.c:189
> >  schedule_debug kernel/sched/core.c:3285 [inline]
> >  __schedule+0x1ec6/0x1ed0 kernel/sched/core.c:3394
> >  preempt_schedule_common+0x1f/0xe0 kernel/sched/core.c:3596
> >  preempt_schedule+0x4d/0x60 kernel/sched/core.c:3622
> >  ___preempt_schedule+0x16/0x18
> >  __raw_spin_unlock_irqrestore include/linux/spinlock_api_smp.h:161 [inline]
> >  _raw_spin_unlock_irqrestore+0xbb/0xd0 kernel/locking/spinlock.c:184
> >  spin_unlock_irqrestore include/linux/spinlock.h:384 [inline]
> >  __remove_mapping+0x932/0x1af0 mm/vmscan.c:967
> >  shrink_page_list+0x6610/0xc2e0 mm/vmscan.c:1461
> >  shrink_inactive_list+0x77b/0x1c60 mm/vmscan.c:1961
> >  shrink_list mm/vmscan.c:2273 [inline]
> >  shrink_node_memcg+0x7a8/0x19a0 mm/vmscan.c:2538
> >  shrink_node+0x3e1/0x17f0 mm/vmscan.c:2753
> >  shrink_zones mm/vmscan.c:2987 [inline]
> >  do_try_to_free_pages+0x3df/0x12a0 mm/vmscan.c:3049
> >  try_to_free_pages+0x4d0/0xb90 mm/vmscan.c:3265
> >  __perform_reclaim mm/page_alloc.c:3920 [inline]
> >  __alloc_pages_direct_reclaim mm/page_alloc.c:3942 [inline]
> >  __alloc_pages_slowpath+0xa5a/0x2db0 mm/page_alloc.c:4335
> >  __alloc_pages_nodemask+0xa89/0xde0 mm/page_alloc.c:4549
> >  alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
> >  alloc_pages include/linux/gfp.h:509 [inline]
> >  __page_cache_alloc+0x38c/0x5b0 mm/filemap.c:924
> >  pagecache_get_page+0x396/0xf00 mm/filemap.c:1615
> >  find_or_create_page include/linux/pagemap.h:322 [inline]
> >  ext4_mb_load_buddy_gfp+0xddf/0x1e70 fs/ext4/mballoc.c:1158
> >  ext4_mb_load_buddy fs/ext4/mballoc.c:1241 [inline]
> >  ext4_mb_regular_allocator+0x634/0x1590 fs/ext4/mballoc.c:2190
> >  ext4_mb_new_blocks+0x1de3/0x4840 fs/ext4/mballoc.c:4538
> >  ext4_ext_map_blocks+0x2eef/0x6180 fs/ext4/extents.c:4404
> >  ext4_map_blocks+0x8f7/0x1b60 fs/ext4/inode.c:636
> >  mpage_map_one_extent fs/ext4/inode.c:2480 [inline]
> >  mpage_map_and_submit_extent fs/ext4/inode.c:2533 [inline]
> >  ext4_writepages+0x2564/0x4170 fs/ext4/inode.c:2884
> >  do_writepages+0x9a/0x1a0 mm/page-writeback.c:2335
> >  __writeback_single_inode+0x20a/0x1660 fs/fs-writeback.c:1316
> >  writeback_sb_inodes+0x71f/0x1210 fs/fs-writeback.c:1580
> >  __writeback_inodes_wb+0x1b9/0x340 fs/fs-writeback.c:1649
> >  wb_writeback+0xa73/0xfc0 fs/fs-writeback.c:1758
> > oom_reaper: reaped process 7963 (syz-executor189), now anon-rss:0kB,
> > file-rss:0kB, shmem-rss:0kB
> > rsyslogd invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0,
> > oom_score_adj=0
> >  wb_check_start_all fs/fs-writeback.c:1882 [inline]
> >  wb_do_writeback fs/fs-writeback.c:1908 [inline]
> >  wb_workfn+0xee9/0x1790 fs/fs-writeback.c:1942
> >  process_one_work+0xc90/0x1c40 kernel/workqueue.c:2153
> >  worker_thread+0x17f/0x1390 kernel/workqueue.c:2296
> >  kthread+0x35a/0x440 kernel/kthread.c:246
> >  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
> > CPU: 1 PID: 7840 Comm: rsyslogd Not tainted 4.20.0+ #396
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google
> > 01/01/2011
> > Call Trace:
> >  __dump_stack lib/dump_stack.c:77 [inline]
> >  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
> >  dump_header+0x253/0x1239 mm/oom_kill.c:451
> >  oom_kill_process.cold.27+0x10/0x903 mm/oom_kill.c:966
> >  out_of_memory+0x8ba/0x1480 mm/oom_kill.c:1133
> >  __alloc_pages_may_oom mm/page_alloc.c:3666 [inline]
> >  __alloc_pages_slowpath+0x230c/0x2db0 mm/page_alloc.c:4379
> >  __alloc_pages_nodemask+0xa89/0xde0 mm/page_alloc.c:4549
> >  alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
> >  alloc_pages include/linux/gfp.h:509 [inline]
> >  __page_cache_alloc+0x38c/0x5b0 mm/filemap.c:924
> >  page_cache_read mm/filemap.c:2373 [inline]
> >  filemap_fault+0x1595/0x25f0 mm/filemap.c:2557
> >  ext4_filemap_fault+0x82/0xad fs/ext4/inode.c:6317
> >  __do_fault+0x100/0x6b0 mm/memory.c:2997
> >  do_read_fault mm/memory.c:3409 [inline]
> >  do_fault mm/memory.c:3535 [inline]
> >  handle_pte_fault mm/memory.c:3766 [inline]
> >  __handle_mm_fault+0x392f/0x5630 mm/memory.c:3890
> >  handle_mm_fault+0x54f/0xc70 mm/memory.c:3927
> >  do_user_addr_fault arch/x86/mm/fault.c:1475 [inline]
> >  __do_page_fault+0x5f6/0xd70 arch/x86/mm/fault.c:1541
> >  do_page_fault+0xf2/0x7e0 arch/x86/mm/fault.c:1572
> >  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1143
> > RIP: 0033:0x7f00f990e1fd
> > Code: Bad RIP value.
> > RSP: 002b:00007f00f6eade30 EFLAGS: 00010293
> > RAX: 0000000000000fd2 RBX: 000000000111f170 RCX: 00007f00f990e1fd
> > RDX: 0000000000000fff RSI: 00007f00f86e25a0 RDI: 0000000000000004
> > RBP: 0000000000000000 R08: 000000000110a260 R09: 0000000000000000
> > R10: 74616c7567657227 R11: 0000000000000293 R12: 000000000065e420
> > R13: 00007f00f6eae9c0 R14: 00007f00f9f53040 R15: 0000000000000003
> > Kernel Offset: disabled
> > Rebooting in 86400 seconds..
> >
> >
> > ---
> > This bug is generated by a bot. It may contain errors.
> > See https://goo.gl/tpsmEJ for more information about syzbot.
> > syzbot engineers can be reached at syzkaller@googlegroups.com.
> >
> > syzbot will keep track of this bug report. See:
> > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with syzbot.
> > syzbot can test patches for this bug, for details see:
> > https://goo.gl/tpsmEJ#testing-patches
> >
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/9fe14b68-5a3c-5964-62b1-53a4ef4c0b76%40lca.pw.
> For more options, visit https://groups.google.com/d/optout.

