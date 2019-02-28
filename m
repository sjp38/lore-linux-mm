Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5CCFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 06:53:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F6DF214D8
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 06:53:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Sy4MZQR4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F6DF214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A21128E0003; Thu, 28 Feb 2019 01:53:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A93D8E0001; Thu, 28 Feb 2019 01:53:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84A808E0003; Thu, 28 Feb 2019 01:53:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 593A58E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:53:23 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id e1so14746016iod.23
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 22:53:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=i3/s5PglH9gxlcaNlP0KMkiKMOrsgOYVB0VY1Idim6o=;
        b=WDoxMYym3T9GHYgj65j/ndALGeuzokZZgFLeOsXCF2GC7Jdra+UilT6Jx+L1xw4aPa
         EJ6coCZM91/h5dTojh4l+7A0QdboM2dcbMX7E74BpWsLJKy6bkz3QtEFep3QA20mePGY
         hut0PJ29qjQeJ8ovUQfayAtyWq/+ndBRyO2M2Y1aFe+p8FFIulX+1FQqn/A1P0lexxA4
         j32hApo62UaOuu+rflyD2xUvvN38MRt3zOQ/AmpqZDzCxRsFsKFGuESfQvh4IpWpvskf
         /pTDQ3DVZyk+gn2FqRyen9puR5MfYVyHmzJX30aJqGD6gs9Ccy3hhP/9RdydVc06boGz
         QJBw==
X-Gm-Message-State: APjAAAVL+LBXr3ELEHxFzHpd2WDeqwjqVqS3IBbnNBGDQ9DriPIw3k/w
	N7ArTun2U/FShpJTzQzHGUd/9ESzL5BCTR9+Ozx+sqGhmxRTGkED6Jj2xT7yAqjABfOJRNBne+u
	APf29mh+RW0r6yppr830n5famQL6zt8GMV3PVLapZvM+XleZfY4I+Ik9USI65bgNmszQ4ToLGkd
	kFFOjTEIOrg++TciTZxBIKY/UlGomRjgbgAFDaibwZQrZDWVme1eVxQK5JQY9BYfHpe3C6L9J7A
	PJ1ytxsmf9sSRC51rIsMyVdNwQH3aUY5Jc4GuqiOjU2Ra99TYIjsQh8sVTJh8VAd5AGeL2Cfgvm
	PeSlVP/gr/Q9CO47dmWso+g4usJv4u0X/G+Dpj8wWjfyhxL7mhbnH2SAKNVaAXWRnb/6OGioGly
	W
X-Received: by 2002:a5e:930d:: with SMTP id k13mr4126115iom.230.1551336803044;
        Wed, 27 Feb 2019 22:53:23 -0800 (PST)
X-Received: by 2002:a5e:930d:: with SMTP id k13mr4126091iom.230.1551336801893;
        Wed, 27 Feb 2019 22:53:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551336801; cv=none;
        d=google.com; s=arc-20160816;
        b=NixjHUyEORii3npjddAxQ6C84T9YC1axneL2l8snF9bHbpcSK+FDx+TwWlqYAoXLYf
         Vpnd9RsaS6+Zm6t5+m3dETdIQ+Oxsn85AAkhGl6wF5Y2uzTgqrEKQRYlk6uwh4SS8Qzx
         M/S5KF4PV5oeh1aUgWKg1p0CyblB4Bqhls3GvMvxvNgA9duIKb7C9ytwCRV1FlLxWGaK
         4N5PUJWnS13rCT3AquFi8sY96NgYGDlwspcQx8VnkctCbdyHHXfTjzEgk9siiWSRpzVm
         kLJbLqy2u1yaD+/dPa/g5n7CVnWZl6r7+i61iXEU2M/VWKqHNXoZt1Zd5AiFofrssX5b
         Wm6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=i3/s5PglH9gxlcaNlP0KMkiKMOrsgOYVB0VY1Idim6o=;
        b=FWmXGVtnDIAYkXm5YCmfOPrqYQS5H8fRmUPfQxle+zm9rNTP6ZTq/y2P2TMv0anSr/
         lKnE/pHEp0relDorX6RwsXwj7GGwF6JL6jlxbG97URuofH07s22/TvsI+qnjwhPiDTXh
         ejAK/yOWCN4MeRr/jgks6mu/qz/S0AUDbgBVWJIhhKuVrrSlX+C420z+l8LmM3W75g/7
         rXj4aEkQ7X8DanF4fd2L9DGUfL+z2MJLu6SvydG7ejhVRtyuqt+kQqBxrQWSqCdyRCTO
         lH+3zVyAtD98In5q1edBHeItyAC9dEioQOtCPBjX0pCJt1qGRDft7bP/nqEwiQqHh0br
         genw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Sy4MZQR4;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor38448733jak.9.2019.02.27.22.53.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 22:53:21 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Sy4MZQR4;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=i3/s5PglH9gxlcaNlP0KMkiKMOrsgOYVB0VY1Idim6o=;
        b=Sy4MZQR4I3yEsBHIGkZYvkvGNPVTMOo746qBMr47WiM0SQaS5ZGjVBU5kDcWtdDUlY
         GNLEbIBLx77WiwJedTtLEoGIN0QkcHAA1nCedJheS82cBft4I0hZI17zv+1kFHVYHvQ8
         3j7yjg5cCWUa+lxdwL2T1ELacXUU9b/dyNvO9DUvF9emkMkYiSSIlq0i+mx+ZLGstEi/
         42bI1e+vKARUZUWd3CtsmQ70y+ADNA+9axkptKPra+n65i8/6SiArpczqHxWWW/zK2GJ
         uRr6g2litZZ2DAcBCanIpRsBpmEMwdIvuj8PtWI+uj245jRnF2VHDfJPpAuJRFzA8DPC
         WARw==
X-Google-Smtp-Source: AHgI3IYkgWOQOJZ0I9PrRVK8rb84Y2Q584t96OHyX+QdRL8KN7SjW2cOx0P5+eNWrJqzUGIlGq6bcnoN8mFyvD3aL1o=
X-Received: by 2002:a02:4985:: with SMTP id p5mr3640499jad.35.1551336801199;
 Wed, 27 Feb 2019 22:53:21 -0800 (PST)
MIME-Version: 1.0
References: <0000000000006a12bd0581ca4145@google.com> <20190213122331.632a4eb1a12b738ef9633855@linux-foundation.org>
 <20190226182129.GA218103@gmail.com> <20190227205323.GA186986@gmail.com>
In-Reply-To: <20190227205323.GA186986@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Feb 2019 07:53:09 +0100
Message-ID: <CACT4Y+ZK5MrJ3GZ-sxihNpRaun4aMOxkRqmLqQJxYEgD2cnfZQ@mail.gmail.com>
Subject: Re: BUG: Bad page state (5)
To: Eric Biggers <ebiggers@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com>, 
	Dan Williams <dan.j.williams@intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, nborisov@suse.com, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Shakeel Butt <shakeelb@google.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Matthew Wilcox <willy@infradead.org>, Joel Fernandes <joel@joelfernandes.org>, 
	Mike Kravetz <kravetz@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 9:53 PM Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Tue, Feb 26, 2019 at 10:21:30AM -0800, Eric Biggers wrote:
> > On Wed, Feb 13, 2019 at 12:23:31PM -0800, Andrew Morton wrote:
> > > On Wed, 13 Feb 2019 09:56:04 -0800 syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com> wrote:
> > >
> > > > Hello,
> > > >
> > > > syzbot found the following crash on:
> > > >
> > > > HEAD commit:    c4f3ef3eb53f Add linux-next specific files for 20190213
> > > > git tree:       linux-next
> > > > console output: https://syzkaller.appspot.com/x/log.txt?x=1130a124c00000
> > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=9ec67976eb2df882
> > > > dashboard link: https://syzkaller.appspot.com/bug?extid=2cd2887ea471ed6e6995
> > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14ecdaa8c00000
> > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12ebe178c00000
> > > >
> > > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > > Reported-by: syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com
> > >
> > > It looks like a a memfd page was freed with a non-NULL ->mapping.
> > >
> > > Joel touched the memfd code with "mm/memfd: add an F_SEAL_FUTURE_WRITE
> > > seal to memfd" but it would be surprising if syzbot tickled that code?
> > >
> > >
> > > > BUG: Bad page state in process udevd  pfn:472f0
> > > > name:"memfd:"
> > > > page:ffffea00011cbc00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xf
> > > > shmem_aops
> > > > flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> > > > raw: 01fffc000008000c ffffea0000ac4f08 ffff8880a85af890 ffff88800df2ad40
> > > > raw: 000000000000000f 0000000000000000 00000000ffffffff 0000000000000000
> > > > page dumped because: non-NULL mapping
> > > > Modules linked in:
> > > > CPU: 1 PID: 7586 Comm: udevd Not tainted 5.0.0-rc6-next-20190213 #34
> > > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > > Google 01/01/2011
> > > > Call Trace:
> > > >   __dump_stack lib/dump_stack.c:77 [inline]
> > > >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> > > >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> > > >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
> > > >   free_pages_check mm/page_alloc.c:1023 [inline]
> > > >   free_pages_prepare mm/page_alloc.c:1113 [inline]
> > > >   free_pcp_prepare mm/page_alloc.c:1138 [inline]
> > > >   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
> > > >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> > > > name:"memfd:"
> > > >   release_pages+0x60d/0x1940 mm/swap.c:791
> > > >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> > > >   __pagevec_lru_add mm/swap.c:917 [inline]
> > > >   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
> > > >   lru_add_drain+0x20/0x60 mm/swap.c:652
> > > >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> > > >   __mmput kernel/fork.c:1047 [inline]
> > > >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> > > >   exec_mmap fs/exec.c:1046 [inline]
> > > >   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
> > > >   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
> > > >   search_binary_handler fs/exec.c:1656 [inline]
> > > >   search_binary_handler+0x17f/0x570 fs/exec.c:1634
> > > >   exec_binprm fs/exec.c:1698 [inline]
> > > >   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
> > > >   do_execveat_common fs/exec.c:1865 [inline]
> > > >   do_execve fs/exec.c:1882 [inline]
> > > >   __do_sys_execve fs/exec.c:1958 [inline]
> > > >   __se_sys_execve fs/exec.c:1953 [inline]
> > > >   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
> > > >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> > > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > RIP: 0033:0x7fc7001ba207
> > > > Code: Bad RIP value.
> > > > RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> > > > RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> > > > RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> > > > RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> > > > R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> > > > R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> > > > BUG: Bad page state in process udevd  pfn:2b13c
> > > > page:ffffea0000ac4f00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xe
> > > > shmem_aops
> > > > flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> > > > raw: 01fffc000008000c ffff8880a85af890 ffff8880a85af890 ffff88800df2ad40
> > > > raw: 000000000000000e 0000000000000000 00000000ffffffff 0000000000000000
> > > > page dumped because: non-NULL mapping
> > > > Modules linked in:
> > > > CPU: 1 PID: 7586 Comm: udevd Tainted: G    B
> > > > 5.0.0-rc6-next-20190213 #34
> > > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > > Google 01/01/2011
> > > > Call Trace:
> > > >   __dump_stack lib/dump_stack.c:77 [inline]
> > > >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> > > >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> > > > name:"memfd:"
> > > >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
> > > >   free_pages_check mm/page_alloc.c:1023 [inline]
> > > >   free_pages_prepare mm/page_alloc.c:1113 [inline]
> > > >   free_pcp_prepare mm/page_alloc.c:1138 [inline]
> > > >   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
> > > >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> > > >   release_pages+0x60d/0x1940 mm/swap.c:791
> > > >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> > > >   __pagevec_lru_add mm/swap.c:917 [inline]
> > > >   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
> > > >   lru_add_drain+0x20/0x60 mm/swap.c:652
> > > >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> > > >   __mmput kernel/fork.c:1047 [inline]
> > > >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> > > >   exec_mmap fs/exec.c:1046 [inline]
> > > >   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
> > > >   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
> > > >   search_binary_handler fs/exec.c:1656 [inline]
> > > >   search_binary_handler+0x17f/0x570 fs/exec.c:1634
> > > >   exec_binprm fs/exec.c:1698 [inline]
> > > >   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
> > > >   do_execveat_common fs/exec.c:1865 [inline]
> > > >   do_execve fs/exec.c:1882 [inline]
> > > >   __do_sys_execve fs/exec.c:1958 [inline]
> > > >   __se_sys_execve fs/exec.c:1953 [inline]
> > > >   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
> > > >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> > > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > RIP: 0033:0x7fc7001ba207
> > > > Code: Bad RIP value.
> > > > RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> > > > RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> > > > RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> > > > RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> > > > R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> > > > R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> > > >
> > > >
> > > > ---
> > > > This bug is generated by a bot. It may contain errors.
> > > > See https://goo.gl/tpsmEJ for more information about syzbot.
> > > > syzbot engineers can be reached at syzkaller@googlegroups.com.
> > > >
> > > > syzbot will keep track of this bug report. See:
> > > > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> > > > syzbot.
> > > > syzbot can test patches for this bug, for details see:
> > > > https://goo.gl/tpsmEJ#testing-patches
> > >
> >
> > It's apparently the bug in the io_uring patchset I reported yesterday (well, I
> > stole it from another open syzbot bug...) and Jens is already planning to fix:
> > https://marc.info/?l=linux-api&m=155115288114046&w=2.  Reproducer is similar,
> > and the crash bisects down to the same commit from the io_uring patchset:
> > "block: implement bio helper to add iter bvec pages to bio".
> >
>
> Fixed in next-20190227.  The fix was folded into "block: implement bio helper to
> add iter bvec pages to bio".  Telling syzbot to invalidate this bug report:
>
> #syz invalid

Was this discovered separately? We could also add Reported-by (or
Tested-by) tag to the commit.

