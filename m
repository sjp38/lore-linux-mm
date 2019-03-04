Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C406FC10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 07:40:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E3DC206B8
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 07:40:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Jqw1/mIe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E3DC206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B71D88E0004; Mon,  4 Mar 2019 02:40:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1F4C8E0001; Mon,  4 Mar 2019 02:40:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0E6F8E0004; Mon,  4 Mar 2019 02:40:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 780F48E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 02:40:30 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id g3so3721712ioh.12
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 23:40:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mNxcrSiCEByRBkhBzvnKSv6lRX2m2/83M0Lin0WFdxQ=;
        b=tpmDYqrB/H0qLNaaIYCO/v0G/e8q+VkPcbQZve7QDi4CCSP+4pFYkyCq/NquhUhBSD
         xQMnBw0nqKQ5Q9/Wj6dqrEOiwHFEVT3q8VjavXk6TZDpAKj7XZE/lknJ6YAK91VQ/czc
         yvem2An//+6rVasZdLbh11AMNw3MQ/hJXFHLZ471vAo0SwtJkcXRh1QbcnQxrrUutlUy
         6vkn9t+k8MFfh5E0/7nTlFXBB+a5HuWfvRjQ7EJESBittGuGvZtYTaiNXm8usjGgdB0z
         yoaFy1hxC6U0N5WsXgndedin2SE338HCLLGEtFHRQTxGvFR56zgdD+86kyQ12w4AE+jS
         3hvw==
X-Gm-Message-State: APjAAAUmiJ/GTiKDkLLSZ9Jpip+NAfVd1bxiBv7R3fivEa39kh1y6qrQ
	6tiRCsv4CpzP3pDbIGEUIZ+2YxvHaqibbjeaMY+HzbCEIAzOpRgds/4hSlboCzoWD/RBs6AvamS
	IxS21I/UNqevkYR3hLZ/GuvHNJaeDL0uIzSXQmdhFBaQQfLdy39hQtPjKvN+BNZ3u+7vCxem1LM
	37x4UQz0gIABPQjpP+VeB7/vGza25pY8yJdA3Ln4SVnbNBbx/CYxT7cXEpov9G5JlH6f16f0sZr
	oUtl9i7NsKh9Gb0Pvg4PDgUoKUIFBpkUPk7S7KM9tjw/QRLbY0Ai9xZoflcm5VXnRrkUIq+dahN
	SYbb/vsWSHOfZ8xpyGLz4y/H86ToxjnitUcewH/KMDc/xMYsq6cwHjaFqKSd5Jy4O7U0ulCs6xf
	5
X-Received: by 2002:a24:68c9:: with SMTP id v192mr8568763itb.64.1551685230168;
        Sun, 03 Mar 2019 23:40:30 -0800 (PST)
X-Received: by 2002:a24:68c9:: with SMTP id v192mr8568740itb.64.1551685228889;
        Sun, 03 Mar 2019 23:40:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551685228; cv=none;
        d=google.com; s=arc-20160816;
        b=h4oxpJKRk8JJM8jWR9yEZZg2NjV9Z0SxDFPYr+rdcUlHBhyHBD8droc9ckM95aNfPk
         5482pK806FokTmVGwSB12yE2BmSXZSEsqiDlE2p/JMb0MLtBlon4vev7xo38HKAhg+mN
         IYRy7hvwmTj+3GN9M6iOxINpsK60e0cCKVr6kk3DTA2bOJMytv5Uc63fbmmxV2Z8A607
         rqkifdl6IECNK2QUuQjtUngGEgzrwFD+jgEJ3ISxdyt5C3C1uGaO82duvnudbZsRxk6P
         3Ekm9fhqgj4fXy45cyrrq/tpORWOJQMoJqyowpS+LaTvkEqIrnWiV8LGAqt+6hRUszoQ
         42gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mNxcrSiCEByRBkhBzvnKSv6lRX2m2/83M0Lin0WFdxQ=;
        b=jqqNm9a5KElHSa2tEF8dS1uj/ODQMwzwo+tEJMkKPUxSvhBjW5DhjCSy7lRKpHmrob
         dwBTaylQXsMXePyuoVZSyIU9Zt8hW9cgNAUdZjw88wbrUrYoJcnopQWYgAEmePfJQdqv
         QXVQKhfy0w8S/9xzSyZlwHNQNwdJmUYgjjZLqyy4F/FyAjOMC+ZRn5a54+eDznkT4Ygr
         y8K2i4pmKmwNNtwhyOLpDPuRwmAzezlyzsGmgxM21m9Uu9WGZwYJApgG3XpUE7HsGkFl
         mgbv5h1FYO0DVddkpVnkqi+k75/e3pZYEW17FT29XgJngZPirZGVRa/0RAq3/242k8CR
         06kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Jqw1/mIe";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19sor1818327ioj.109.2019.03.03.23.40.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Mar 2019 23:40:28 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Jqw1/mIe";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mNxcrSiCEByRBkhBzvnKSv6lRX2m2/83M0Lin0WFdxQ=;
        b=Jqw1/mIe5vq9NDjcGNvA8LlSMLA5KgcMHHSqqwr53MaBWvV/ouA1OAjam1Am1zbPwh
         PaypYp9BTqW2NAoxMcx99lQPUGEmKn7Mj06H6pmt34xiMjJHn3+s2a+GsRtNIfr1WaFi
         JRgE7RR5hE6KDmavWuwU2oDCArQVGcCNRYuHPZCtzSlLNsNH1OvlhD7e3+JRumuJdEJX
         VdeWlxRqbAAj7OwQk7wrzjQ62wYGhe415WvjM+ro0+A2mpDCBLkz6Uyg01/j0MsHuJV3
         5P8EsZ9GL3myoRT9EpT5ioDdDWIM5vcgcG6i3uZ0Sd7Fah63SFHBCK68Vy1mUXx9m9q6
         xXkw==
X-Google-Smtp-Source: APXvYqzgQwzaX1um8y7pstwcCrz/1lulCUFYehpHK/g15Tk7QvNKNUr+kncHTDITLRLRcwj/NOv5RwxDf2pDZSZA+Dc=
X-Received: by 2002:a5d:84c3:: with SMTP id z3mr9164568ior.11.1551685228249;
 Sun, 03 Mar 2019 23:40:28 -0800 (PST)
MIME-Version: 1.0
References: <00000000000006457e057c341ff8@google.com> <5C7BFE94.6070500@huawei.com>
In-Reply-To: <5C7BFE94.6070500@huawei.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 4 Mar 2019 08:40:16 +0100
Message-ID: <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
To: zhong jiang <zhongjiang@huawei.com>
Cc: syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>, 
	Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, cgroups@vger.kernel.org, 
	Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, 
	Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Mel Gorman <mgorman@suse.de>, 
	Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 3, 2019 at 5:19 PM zhong jiang <zhongjiang@huawei.com> wrote:
>
> Hi, guys
>
> I also hit the following issue. but it fails to reproduce the issue by the log.
>
> it seems to the case that we access the mm->owner and deference it will result in the UAF.
> But it should not be possible that we specify the incomplete process to be the mm->owner.
>
> Any thoughts?

FWIW syzbot was able to reproduce this with this reproducer.
This looks like a very subtle race (threaded reproducer that runs
repeatedly in multiple processes), so most likely we are looking for
something like few instructions inconsistency window.


> Thanks,
> zhong jiang
>
> On 2018/12/4 23:43, syzbot wrote:
> > syzbot has found a reproducer for the following crash on:
> >
> > HEAD commit:    0072a0c14d5b Merge tag 'media/v4.20-4' of git://git.kernel..
> > git tree:       upstream
> > console output: https://syzkaller.appspot.com/x/log.txt?x=11c885a3400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=b9cc5a440391cbfd
> > dashboard link: https://syzkaller.appspot.com/bug?extid=cbb52e396df3e565ab02
> > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12835e25400000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=172fa5a3400000
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
> >
> > cgroup: fork rejected by pids controller in /syz2
> > ==================================================================
> > BUG: KASAN: use-after-free in __read_once_size include/linux/compiler.h:182 [inline]
> > BUG: KASAN: use-after-free in task_css include/linux/cgroup.h:477 [inline]
> > BUG: KASAN: use-after-free in mem_cgroup_from_task mm/memcontrol.c:815 [inline]
> > BUG: KASAN: use-after-free in get_mem_cgroup_from_mm.part.62+0x6d7/0x880 mm/memcontrol.c:844
> > Read of size 8 at addr ffff8881b72af310 by task syz-executor198/9332
> >
> > CPU: 0 PID: 9332 Comm: syz-executor198 Not tainted 4.20.0-rc5+ #142
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> > Call Trace:
> >  __dump_stack lib/dump_stack.c:77 [inline]
> >  dump_stack+0x244/0x39d lib/dump_stack.c:113
> >  print_address_description.cold.7+0x9/0x1ff mm/kasan/report.c:256
> >  kasan_report_error mm/kasan/report.c:354 [inline]
> >  kasan_report.cold.8+0x242/0x309 mm/kasan/report.c:412
> >  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
> >  __read_once_size include/linux/compiler.h:182 [inline]
> >  task_css include/linux/cgroup.h:477 [inline]
> >  mem_cgroup_from_task mm/memcontrol.c:815 [inline]
> >  get_mem_cgroup_from_mm.part.62+0x6d7/0x880 mm/memcontrol.c:844
> >  get_mem_cgroup_from_mm mm/memcontrol.c:834 [inline]
> >  mem_cgroup_try_charge+0x608/0xe20 mm/memcontrol.c:5888
> >  mcopy_atomic_pte mm/userfaultfd.c:71 [inline]
> >  mfill_atomic_pte mm/userfaultfd.c:418 [inline]
> >  __mcopy_atomic mm/userfaultfd.c:559 [inline]
> >  mcopy_atomic+0xb08/0x2c70 mm/userfaultfd.c:609
> >  userfaultfd_copy fs/userfaultfd.c:1705 [inline]
> >  userfaultfd_ioctl+0x29fb/0x5610 fs/userfaultfd.c:1851
> >  vfs_ioctl fs/ioctl.c:46 [inline]
> >  file_ioctl fs/ioctl.c:509 [inline]
> >  do_vfs_ioctl+0x1de/0x1790 fs/ioctl.c:696
> >  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:713
> >  __do_sys_ioctl fs/ioctl.c:720 [inline]
> >  __se_sys_ioctl fs/ioctl.c:718 [inline]
> >  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:718
> >  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > RIP: 0033:0x44c7e9
> > Code: 5d c5 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 2b c5 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> > RSP: 002b:00007f906b69fdb8 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
> > RAX: ffffffffffffffda RBX: 00000000006e4a08 RCX: 000000000044c7e9
> > RDX: 0000000020000100 RSI: 00000000c028aa03 RDI: 0000000000000004
> > RBP: 00000000006e4a00 R08: 0000000000000000 R09: 0000000000000000
> > R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006e4a0c
> > R13: 00007ffdfd47813f R14: 00007f906b6a09c0 R15: 000000000000002d
> >
> > Allocated by task 9325:
> >  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
> >  set_track mm/kasan/kasan.c:460 [inline]
> >  kasan_kmalloc+0xc7/0xe0 mm/kasan/kasan.c:553
> >  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
> >  kmem_cache_alloc_node+0x144/0x730 mm/slab.c:3644
> >  alloc_task_struct_node kernel/fork.c:158 [inline]
> >  dup_task_struct kernel/fork.c:843 [inline]
> >  copy_process+0x2026/0x87a0 kernel/fork.c:1751
> >  _do_fork+0x1cb/0x11d0 kernel/fork.c:2216
> >  __do_sys_clone kernel/fork.c:2323 [inline]
> >  __se_sys_clone kernel/fork.c:2317 [inline]
> >  __x64_sys_clone+0xbf/0x150 kernel/fork.c:2317
> >  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >
> > Freed by task 9325:
> >  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
> >  set_track mm/kasan/kasan.c:460 [inline]
> >  __kasan_slab_free+0x102/0x150 mm/kasan/kasan.c:521
> >  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
> >  __cache_free mm/slab.c:3498 [inline]
> >  kmem_cache_free+0x83/0x290 mm/slab.c:3760
> >  free_task_struct kernel/fork.c:163 [inline]
> >  free_task+0x16e/0x1f0 kernel/fork.c:457
> >  copy_process+0x1dcc/0x87a0 kernel/fork.c:2148
> >  _do_fork+0x1cb/0x11d0 kernel/fork.c:2216
> >  __do_sys_clone kernel/fork.c:2323 [inline]
> >  __se_sys_clone kernel/fork.c:2317 [inline]
> >  __x64_sys_clone+0xbf/0x150 kernel/fork.c:2317
> >  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >
> > The buggy address belongs to the object at ffff8881b72ae240
> >  which belongs to the cache task_struct(81:syz2) of size 6080
> > The buggy address is located 4304 bytes inside of
> >  6080-byte region [ffff8881b72ae240, ffff8881b72afa00)
> > The buggy address belongs to the page:
> > page:ffffea0006dcab80 count:1 mapcount:0 mapping:ffff8881d2dce0c0 index:0x0 compound_mapcount: 0
> > flags: 0x2fffc0000010200(slab|head)
> > raw: 02fffc0000010200 ffffea00074a1f88 ffffea0006ebbb88 ffff8881d2dce0c0
> > raw: 0000000000000000 ffff8881b72ae240 0000000100000001 ffff8881d87fe580
> > page dumped because: kasan: bad access detected
> > page->mem_cgroup:ffff8881d87fe580
> >
> > Memory state around the buggy address:
> >  ffff8881b72af200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >  ffff8881b72af280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> ffff8881b72af300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >                          ^
> >  ffff8881b72af380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >  ffff8881b72af400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > ==================================================================
> >
> >
> > .
> >
>
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/5C7BFE94.6070500%40huawei.com.
> For more options, visit https://groups.google.com/d/optout.

