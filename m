Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81613C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 21:51:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14F82206B6
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 21:51:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Nt2nP1Z8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14F82206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AC908E0003; Mon,  4 Mar 2019 16:51:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 432668E0001; Mon,  4 Mar 2019 16:51:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D45D8E0003; Mon,  4 Mar 2019 16:51:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDDFB8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 16:51:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e4so6767497pfh.14
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 13:51:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=M1LlA0O36py7SEZ7WWbUKLyA+ZRRYPvZmGqyNruBKA4=;
        b=qZBYPMnls+WYQLbZdmNkHJTA4QeI/BWGNkdw7ekWKCBG0KCnjC7hAKOm4ZPz6JhdEt
         Ep/+OXSLt0953Eemsgq2Tg4ab+sMrzi0otthTkys4hvdvzEqhdnpd8N0YoFS+hWJjKBD
         4fwKAs9oq1ONHKN14Gw0IQ99a/BqGcqDJOsuBRA1r3N287wO5geN5+xjAxpSGP7N6djd
         pxQir06E0D9RA4cW15Q2qPssgskvMUv1TfKWXUGp/R2j+h/EH8x+C/my1cv+8SZb853F
         QSso9hHoyQ/uTntqduORkuNeIuC1hf6G0dXxh7QQgqfpLmJB3KdCqthlRii5zydlccxa
         dWmQ==
X-Gm-Message-State: APjAAAWKG4+g6GHG9m0NySOqP57Re0nVVf9o8W9VHJ5OdYuw/yRJfr4t
	X8PxARJVpAx74do+4P7Ogi1/88XB2HIkuR7k2ApcKFnD1SS7WiTiWfItio3Yiv4X3+V8FLP9bCU
	kGdoWh0TEwmZMiiB7kSjC6C02DAhFivq+kJIQKHnmOxVwuq1A1l48oF0GW2wvTjTpog==
X-Received: by 2002:a63:1960:: with SMTP id 32mr20251822pgz.171.1551736279392;
        Mon, 04 Mar 2019 13:51:19 -0800 (PST)
X-Google-Smtp-Source: APXvYqxGpFeS5IAE0aJN8H4ekJWxi5trH+bidLu4db4VT17GGX0YOhUDB9nCKrj33TzD2Rcdi7NF
X-Received: by 2002:a63:1960:: with SMTP id 32mr20251740pgz.171.1551736277665;
        Mon, 04 Mar 2019 13:51:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551736277; cv=none;
        d=google.com; s=arc-20160816;
        b=IQttL4EqPYNryJDDBEtzoGr6v7PkJ2TwTjRT21fOP5Ymfa4UhAjy3WeSgq6vKM/YJm
         FLqOI/qOuxlxVkYZC6TtQO/EzC6v9/QoBYug5vFwNbaNllXo24N9kT7JuHQsQExfX0jO
         /25q25lW03a06NgIeibBZHxmM/P+yygssLgAuKx5drrOUe8pniIOcQvS6s4uOgwVrH/G
         LmGuNUrjA1ndx49XusTkJnwZmaN0FDyczd2eCfBSISgjfvA70u+93UUo24pODNCpn+PI
         upNTjc0sI6u/1KIgwxKvIigJNA4cWWK8QlPlJmawybaoEDxBtAw8moEKApBop5sJWD9+
         6erw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=M1LlA0O36py7SEZ7WWbUKLyA+ZRRYPvZmGqyNruBKA4=;
        b=bDMvCB0o8ii7MZBRuXB9RD0YyvIR2VH6H/9DmNeprb1obI3i7sRVrNV364tsTIQUv4
         PHc3sj3+mtHd1+c2hFW3vLplpHHJLClGWD4+LI78LbR0A9EKZn+Vxp9gYKHq5LP2/jB/
         9fa0UqDlV5YTEspINn0/hGhoY0R/UXN4xgwFk2JQyjW9LEvLThy7eIFYyBd4CQAFBUEF
         D4irkPwJhkgD9ypIiYYUgi5zwhtqWe7KJSTnNT3hhS7UJPov+kX5an7P5PORCXhRMwmL
         K0rPV0xADZttN1tleECOAJpHOVmQVMqjFSrFi+nZj08G4ILs3NXCXwz/x5mvbF1h6exQ
         43ZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Nt2nP1Z8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 71si6584256plb.8.2019.03.04.13.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Mar 2019 13:51:17 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Nt2nP1Z8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=M1LlA0O36py7SEZ7WWbUKLyA+ZRRYPvZmGqyNruBKA4=; b=Nt2nP1Z8JtE6FCIldaO0qHxZi
	N6iZiUWufNrLBmnPTG0OSzfanxAvuW9/3G4fqiknG8gqxGHUoDMbLSpWfTDpybqL3RORiKzol9Vjb
	vFttS1WnS5GdMbU6GeayST0/y33vUeKdcN/UdZrWOHWIe548/+PfBBnsnIQjb5Y3As/ZmCFc4MfIp
	1kCPRteXOXxdNkUJZDiD5y+4dwrUp5a9rR2nxmYOx7HTHFEwBznKeEKnbuW4tiPexREkAbDY9bnVm
	YnWjQRo3KevLLSCNnc2aiqlqOLvE0F/p25a78hJ6WsIg6tSvAFvNyVPVwmmBhlsv1Zedfx5vzkWQ0
	HLLeLwwzA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h0vUO-0007Un-8q; Mon, 04 Mar 2019 21:51:12 +0000
Date: Mon, 4 Mar 2019 13:51:12 -0800
From: Matthew Wilcox <willy@infradead.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>,
	mhocko@kernel.org, Andrea Arcangeli <aarcange@redhat.com>,
	cgroups@vger.kernel.org, hannes@cmpxchg.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com,
	David Rientjes <rientjes@google.com>,
	Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
Message-ID: <20190304215111.GA13380@bombadil.infradead.org>
References: <00000000000006457e057c341ff8@google.com>
 <5C7BFE94.6070500@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5C7BFE94.6070500@huawei.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 12:19:32AM +0800, zhong jiang wrote:
> I also hit the following issue. but it fails to reproduce the issue by the log.
> 
> it seems to the case that we access the mm->owner and deference it will result in the UAF.
> But it should not be possible that we specify the incomplete process to be the mm->owner.

OK, so we've got thread 9325 calling fork() and failing due to the PID
controller saying "no".  9325 calls free_task(), but somehow thread 9332
has a reference to the struct task_struct.  There are two possibilities
here: one is that 9332 really did manage to get a reference to the larval
child of 9325, and the other is that 9332 has a stale reference to some
memory which was reallocated to 9325's child.

Andrea, is there any way for a UFFD thread to get access to the child's
task_struct during the copy_process() call?  If so, I think copy_process()
needs to call mm_update_next_owner().

If there's no way for that to happen, then we have quite a bug-hunt ahead
of us looking for who is missing a call to mm_update_next_owner().

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

