Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23569C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 07:59:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C10D22184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 07:59:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="P8MJ9Ex5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C10D22184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61FA28E0003; Thu, 28 Feb 2019 02:59:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CF598E0001; Thu, 28 Feb 2019 02:59:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BF6B8E0003; Thu, 28 Feb 2019 02:59:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09BDE8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:59:48 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id z14so11179177pgu.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 23:59:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NU5ZMaq67xtQ/LcHptOakMXp0ZrmGwTYNDHBPdDCDk0=;
        b=oPSnSQOLd8Rujpkp5LS8HoCuzBjkpLUWgw1M3f5W8PWm3p1lI5BKuAbaUq6fb5PU4V
         5JfQpK6wnQu0smtc1T/dsbfEdc97h0YlC77CMnGC8yHg/pqbr/V+3aRiNWY5cZX4NC0f
         QJhGbik2NomKgafxHc4oTmTjIrG7YxRhUd9RKZv/oRnwAvuMUKZJ+ByhuIcAdD6Gzp3k
         Q4YwHUxGkuSr/lCgBVp3rWgkJTjNgulePik24OOss5cF4Pv+Zd5o/9nW1UCL2NZbsTb2
         70QRho8DdD2eXhI1sja05pzQZFBg9f14bRqno6y2BxQeXfmgOEfLfD4jsd/kzt0XKZG4
         sYFQ==
X-Gm-Message-State: AHQUAuZkddE7C5w3Q2PYpeQUWQeiGd9cQnmoj6TuJZXupsMrF9V4xgAf
	zrU4aZBS4YrCvl25+btstmm7um2IkTxYslOdUBlFo5dPlACxO6qp0mG0tjagkpVHd3zNndq10D6
	0+UhOJiMRsGN0qPk9OOctuIrQdnSa4gb9tcoPclXaUGtvhuwPUaB7sQtTaxRW2WpTkQ==
X-Received: by 2002:a63:3548:: with SMTP id c69mr7347421pga.256.1551340787641;
        Wed, 27 Feb 2019 23:59:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZjwfa+4eA0zmUCykEtTFoCnr9hJtPZ5yhN5D8Njl4xRNGN7m6TxLv/cymPp5+Laq2KUlr9
X-Received: by 2002:a63:3548:: with SMTP id c69mr7347352pga.256.1551340786268;
        Wed, 27 Feb 2019 23:59:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551340786; cv=none;
        d=google.com; s=arc-20160816;
        b=bewnZ2r/8qRREh+w76PdnRAP386Yr82RWqSA3+JpUYT28DJfs/PxfA1Zh1NXrmc4uz
         ld/6tBMA1BsLqFEspkKpbYc3Hq5eB/mLWpSvf+69PjX//hvleuOCOD8QrX1FOhcsx0l2
         eOU9cTAtACnnLegeP8s4CNqDs8ygbmvT5v95uS3Ajc0cDTV6coqGBK0g4WEOy+VaGog0
         qsoUqjjtZHBaVmKeC917NG0X6DBk7nNeKct3ioMJnuB0Jb0PNgfJkFrHQFyrSxgr1FEj
         lwq5lg5GrYodkoOkvNNRaicLaTimFPKWV/9CW92lh6mS+XQDs7qktx0Q/atPync8Sehv
         NP2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NU5ZMaq67xtQ/LcHptOakMXp0ZrmGwTYNDHBPdDCDk0=;
        b=gBrcT23zj2XKtPsBXLjwqmYC9OfBcq4iotwA3JxfDDHSy7/9fd37D/eG1haAAx21LX
         A6KtGMiymuIN3xsD6PIvPW9+hjgkuCIzds5xZWHKpMt2dbgYTuBcz6cf6IZUOkXUs2WY
         iE0YROe4E/yl5b0ffWRkYcLCClyIJxJaEQgM2v59LX1+8ddpIEkvzf2k2vBEN79LhbVs
         eClSLB7O5+nmFBuzNGzSSutV8pewQ7ahtBoUNmu8ZfI4/R7aZv0TuThVurvh45YuVj3K
         FhtzCa3UZczR696N6GIKky/B1TbSWhK9d3z6Pp8kWbSGpxjau4xssO8a2Bmh/w54izvk
         1+qw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=P8MJ9Ex5;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j66si18528032pfb.182.2019.02.27.23.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 23:59:46 -0800 (PST)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=P8MJ9Ex5;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sol.localdomain (c-107-3-167-184.hsd1.ca.comcast.net [107.3.167.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6F74E2171F;
	Thu, 28 Feb 2019 07:59:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551340785;
	bh=NcIlYuUhM73vAOXf20/GEHGjl7NNca2Pi8H7hzWo9ws=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=P8MJ9Ex5F5gXPWEz4et8QYGzzSZx5js4/w8OhKN8hAQ8nCp/gh3bmcoa4KHZOzoLa
	 rXtBXB8Inc6TYRXhmxl+YA3WlcNPU2gVf0tCLzklqu9Ok3VRf4V0DLaPudJnVVDl8J
	 v45RhjBZUzxlHsGILftONi2P4xc5SU5cCOjXlvF8=
Date: Wed, 27 Feb 2019 23:59:43 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com>,
	Dan Williams <dan.j.williams@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>, nborisov@suse.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Shakeel Butt <shakeelb@google.com>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: BUG: Bad page state (5)
Message-ID: <20190228075943.GG699@sol.localdomain>
References: <0000000000006a12bd0581ca4145@google.com>
 <20190213122331.632a4eb1a12b738ef9633855@linux-foundation.org>
 <20190226182129.GA218103@gmail.com>
 <20190227205323.GA186986@gmail.com>
 <CACT4Y+ZK5MrJ3GZ-sxihNpRaun4aMOxkRqmLqQJxYEgD2cnfZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZK5MrJ3GZ-sxihNpRaun4aMOxkRqmLqQJxYEgD2cnfZQ@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 07:53:09AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> On Wed, Feb 27, 2019 at 9:53 PM Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > On Tue, Feb 26, 2019 at 10:21:30AM -0800, Eric Biggers wrote:
> > > On Wed, Feb 13, 2019 at 12:23:31PM -0800, Andrew Morton wrote:
> > > > On Wed, 13 Feb 2019 09:56:04 -0800 syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com> wrote:
> > > >
> > > > > Hello,
> > > > >
> > > > > syzbot found the following crash on:
> > > > >
> > > > > HEAD commit:    c4f3ef3eb53f Add linux-next specific files for 20190213
> > > > > git tree:       linux-next
> > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=1130a124c00000
> > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=9ec67976eb2df882
> > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=2cd2887ea471ed6e6995
> > > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14ecdaa8c00000
> > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12ebe178c00000
> > > > >
> > > > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > > > Reported-by: syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com
> > > >
> > > > It looks like a a memfd page was freed with a non-NULL ->mapping.
> > > >
> > > > Joel touched the memfd code with "mm/memfd: add an F_SEAL_FUTURE_WRITE
> > > > seal to memfd" but it would be surprising if syzbot tickled that code?
> > > >
> > > >
> > > > > BUG: Bad page state in process udevd  pfn:472f0
> > > > > name:"memfd:"
> > > > > page:ffffea00011cbc00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xf
> > > > > shmem_aops
> > > > > flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> > > > > raw: 01fffc000008000c ffffea0000ac4f08 ffff8880a85af890 ffff88800df2ad40
> > > > > raw: 000000000000000f 0000000000000000 00000000ffffffff 0000000000000000
> > > > > page dumped because: non-NULL mapping
> > > > > Modules linked in:
> > > > > CPU: 1 PID: 7586 Comm: udevd Not tainted 5.0.0-rc6-next-20190213 #34
> > > > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > > > Google 01/01/2011
> > > > > Call Trace:
> > > > >   __dump_stack lib/dump_stack.c:77 [inline]
> > > > >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> > > > >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> > > > >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
> > > > >   free_pages_check mm/page_alloc.c:1023 [inline]
> > > > >   free_pages_prepare mm/page_alloc.c:1113 [inline]
> > > > >   free_pcp_prepare mm/page_alloc.c:1138 [inline]
> > > > >   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
> > > > >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> > > > > name:"memfd:"
> > > > >   release_pages+0x60d/0x1940 mm/swap.c:791
> > > > >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> > > > >   __pagevec_lru_add mm/swap.c:917 [inline]
> > > > >   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
> > > > >   lru_add_drain+0x20/0x60 mm/swap.c:652
> > > > >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> > > > >   __mmput kernel/fork.c:1047 [inline]
> > > > >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> > > > >   exec_mmap fs/exec.c:1046 [inline]
> > > > >   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
> > > > >   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
> > > > >   search_binary_handler fs/exec.c:1656 [inline]
> > > > >   search_binary_handler+0x17f/0x570 fs/exec.c:1634
> > > > >   exec_binprm fs/exec.c:1698 [inline]
> > > > >   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
> > > > >   do_execveat_common fs/exec.c:1865 [inline]
> > > > >   do_execve fs/exec.c:1882 [inline]
> > > > >   __do_sys_execve fs/exec.c:1958 [inline]
> > > > >   __se_sys_execve fs/exec.c:1953 [inline]
> > > > >   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
> > > > >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> > > > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > > RIP: 0033:0x7fc7001ba207
> > > > > Code: Bad RIP value.
> > > > > RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> > > > > RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> > > > > RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> > > > > RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> > > > > R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> > > > > R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> > > > > BUG: Bad page state in process udevd  pfn:2b13c
> > > > > page:ffffea0000ac4f00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xe
> > > > > shmem_aops
> > > > > flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> > > > > raw: 01fffc000008000c ffff8880a85af890 ffff8880a85af890 ffff88800df2ad40
> > > > > raw: 000000000000000e 0000000000000000 00000000ffffffff 0000000000000000
> > > > > page dumped because: non-NULL mapping
> > > > > Modules linked in:
> > > > > CPU: 1 PID: 7586 Comm: udevd Tainted: G    B
> > > > > 5.0.0-rc6-next-20190213 #34
> > > > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > > > Google 01/01/2011
> > > > > Call Trace:
> > > > >   __dump_stack lib/dump_stack.c:77 [inline]
> > > > >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> > > > >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> > > > > name:"memfd:"
> > > > >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
> > > > >   free_pages_check mm/page_alloc.c:1023 [inline]
> > > > >   free_pages_prepare mm/page_alloc.c:1113 [inline]
> > > > >   free_pcp_prepare mm/page_alloc.c:1138 [inline]
> > > > >   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
> > > > >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> > > > >   release_pages+0x60d/0x1940 mm/swap.c:791
> > > > >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> > > > >   __pagevec_lru_add mm/swap.c:917 [inline]
> > > > >   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
> > > > >   lru_add_drain+0x20/0x60 mm/swap.c:652
> > > > >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> > > > >   __mmput kernel/fork.c:1047 [inline]
> > > > >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> > > > >   exec_mmap fs/exec.c:1046 [inline]
> > > > >   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
> > > > >   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
> > > > >   search_binary_handler fs/exec.c:1656 [inline]
> > > > >   search_binary_handler+0x17f/0x570 fs/exec.c:1634
> > > > >   exec_binprm fs/exec.c:1698 [inline]
> > > > >   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
> > > > >   do_execveat_common fs/exec.c:1865 [inline]
> > > > >   do_execve fs/exec.c:1882 [inline]
> > > > >   __do_sys_execve fs/exec.c:1958 [inline]
> > > > >   __se_sys_execve fs/exec.c:1953 [inline]
> > > > >   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
> > > > >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> > > > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > > RIP: 0033:0x7fc7001ba207
> > > > > Code: Bad RIP value.
> > > > > RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> > > > > RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> > > > > RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> > > > > RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> > > > > R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> > > > > R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> > > > >
> > > > >
> > > > > ---
> > > > > This bug is generated by a bot. It may contain errors.
> > > > > See https://goo.gl/tpsmEJ for more information about syzbot.
> > > > > syzbot engineers can be reached at syzkaller@googlegroups.com.
> > > > >
> > > > > syzbot will keep track of this bug report. See:
> > > > > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> > > > > syzbot.
> > > > > syzbot can test patches for this bug, for details see:
> > > > > https://goo.gl/tpsmEJ#testing-patches
> > > >
> > >
> > > It's apparently the bug in the io_uring patchset I reported yesterday (well, I
> > > stole it from another open syzbot bug...) and Jens is already planning to fix:
> > > https://marc.info/?l=linux-api&m=155115288114046&w=2.  Reproducer is similar,
> > > and the crash bisects down to the same commit from the io_uring patchset:
> > > "block: implement bio helper to add iter bvec pages to bio".
> > >
> >
> > Fixed in next-20190227.  The fix was folded into "block: implement bio helper to
> > add iter bvec pages to bio".  Telling syzbot to invalidate this bug report:
> >
> > #syz invalid
> 
> Was this discovered separately? We could also add Reported-by (or
> Tested-by) tag to the commit.
> 

My report was based on a crash from the syzbot dashboard.  However, there's no
fixing commit, as the fix was folded into the original patch.  I.e. the mainline
git history (if/when the io_uring stuff is actually merged) won't show the bug
ever being introduced.  Thus Reported-by isn't appropriate, and I used '#syz
invalid' instead of '#syz fix'.  Nor did syzbot specifically test the new
version of the patch beyond fuzzing the next day's linux-next...  So while I
personally might have added an informal note in the commit message, I don't
think those formal tags make sense for folded-in linux-next fixes like this.

- Eric

