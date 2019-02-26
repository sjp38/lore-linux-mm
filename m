Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4915C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 18:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8352E21871
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 18:21:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="DZaTbBZo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8352E21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 064AD8E0003; Tue, 26 Feb 2019 13:21:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F07048E0001; Tue, 26 Feb 2019 13:21:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA8F38E0003; Tue, 26 Feb 2019 13:21:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 945A48E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 13:21:34 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f18so9565919pfd.1
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:21:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=t07+gbYdjUHl7ug4Lv5jXPfz0cZtbWC0xdMKDQqxtxI=;
        b=Yn9RERAM4vKik8B8Lbc+77UqzzKQztZt0ywJayGMEfI6zCGifMVm7ZdO14gj+O93YS
         8N5NhrU20E/uULQSXPlc5E+mw/tdAozcE9BY2DiBNJEnm+b0T/rOskOA5kbwcXQZKldU
         /ZNF4Ak7Zt9A7nO8UZWmMAv68sL569KcIleN3HszG/MwKHQsCkVQ5/a1bUmu2gJeVT8u
         fyAaBx574m2LEzkzIeVol4SYKP8XU0m1KNLVTuzAFqQwL659hzrQnqHc+8H7LlwBJoNX
         9fpUXynx8GdGOJIVIA2ieQaUdnMssUfW+L8LsTMqVJdAmmCKzy70F/iWvr1nYKLl9jLj
         OpGg==
X-Gm-Message-State: AHQUAub3xryYH/F7vxxbxAhGbRiD9nrB6r4o4+KS7Nk/LkwdSsqYFupG
	zLwwNmAMuAD8X8ljNuhksET3AQolNI7aqCRcfK/pu0J/4n6wY3EROflelWIrNzFFTToa4uV3jZ8
	3xQ6mtiMGsxuTAZa92Bw12fC4PxUCp78u0BUixjCDOj+XMDeB5+5wBttH+5MJ3h55gA==
X-Received: by 2002:a17:902:1aa:: with SMTP id b39mr17224831plb.317.1551205294102;
        Tue, 26 Feb 2019 10:21:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbNfpUqH1EQ6lq39sDj/nN1ojzSnAkPn42zYuux9ggn8jVPoi4bAIePsOEuGuUsasVbPxN2
X-Received: by 2002:a17:902:1aa:: with SMTP id b39mr17224715plb.317.1551205292723;
        Tue, 26 Feb 2019 10:21:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551205292; cv=none;
        d=google.com; s=arc-20160816;
        b=p+ds4YcteaPtLUhZ1hU7YCA5xNQ7KoCv9aoYzDNQdHP/BCMjHqoYCFTuoQKFUXGBEL
         PBf15ZbRalPooCAO/bZhFcTMzM7iPwaSlWjsKNP5MCx/AM3QZgsE0diC6NAZyTGR34Pt
         AXpLZVD+vhSpQKXwQv4jILXFCE87cKjPBD9Zmq4ngvstLEpJSSiJb4FTrm9ru7ySPtsR
         bncz8MaiQsOjN1fzqb18Z3+mx//W5cwl0b2+etA5npHXETJFzLdvNKr3eB1AkRxURmW2
         KA9KPceWjINGd6UBJ1p7m4YJUJhH074XmMyUwj4oHI19/6TJAfLgR9/J9P++5GQIA7Ms
         tk3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=t07+gbYdjUHl7ug4Lv5jXPfz0cZtbWC0xdMKDQqxtxI=;
        b=HwdvklH8AiqyQgug3yXq43GrPB8C4MYiRDgFL63N0BjE3Nx8kDO6UbRGbITeJVZ7jm
         iG1pAA5MSr1ZaQgMKGDKB8QIH9SmMvH8sS7ONL9q1h1WJKSxFInbPAwY7v1iULoN1hKA
         smyrY8+WQLbG3hCfZBRWYGo3NuRX6NP3HozcgDW4QhGGAucrvQzlXY4EA/6gYwlGpR/a
         RD1KWmT02QoDbxZxgsK02emWWsdwRpBpMg9KbsxSUqmMF+CIFMM1LmnZHoa3GTRPfStC
         UF9yrw5SiAYo1k0GZBaP0/yj5ieuIWZQZCin0thNESZ0d/lUVr8w09jEwmXkBVFllQgf
         r62Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DZaTbBZo;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t2si810465pgp.444.2019.02.26.10.21.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 10:21:32 -0800 (PST)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DZaTbBZo;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from gmail.com (unknown [104.132.1.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F1C75217F5;
	Tue, 26 Feb 2019 18:21:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551205292;
	bh=BysDzC78+3Ctu9/fw7kBXOLKrjOe9w8Qa++TLCVpipo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=DZaTbBZo/bE6Gc8SEELxuVnI+MtwLNdJ0w3sVkm/sNltU3rdNEIpLcfshuNPdI4m3
	 7zw6qVt2FRQO6TPIB+cmQi52L2u9PpVReu0iwfKEdB6BP+JJvD8DSbEBaj70MlbLVB
	 4vQuq9Q7GRUOK8j2HXaEboBI27Yao+tJ3v63PfhY=
Date: Tue, 26 Feb 2019 10:21:30 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com>,
	dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mhocko@suse.com, nborisov@suse.com,
	rppt@linux.vnet.ibm.com, shakeelb@google.com,
	syzkaller-bugs@googlegroups.com, vbabka@suse.cz,
	willy@infradead.org, joel@joelfernandes.org,
	Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: BUG: Bad page state (5)
Message-ID: <20190226182129.GA218103@gmail.com>
References: <0000000000006a12bd0581ca4145@google.com>
 <20190213122331.632a4eb1a12b738ef9633855@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213122331.632a4eb1a12b738ef9633855@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 12:23:31PM -0800, Andrew Morton wrote:
> On Wed, 13 Feb 2019 09:56:04 -0800 syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com> wrote:
> 
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    c4f3ef3eb53f Add linux-next specific files for 20190213
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=1130a124c00000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=9ec67976eb2df882
> > dashboard link: https://syzkaller.appspot.com/bug?extid=2cd2887ea471ed6e6995
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14ecdaa8c00000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12ebe178c00000
> > 
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com
> 
> It looks like a a memfd page was freed with a non-NULL ->mapping.
> 
> Joel touched the memfd code with "mm/memfd: add an F_SEAL_FUTURE_WRITE
> seal to memfd" but it would be surprising if syzbot tickled that code?
> 
> 
> > BUG: Bad page state in process udevd  pfn:472f0
> > name:"memfd:"
> > page:ffffea00011cbc00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xf
> > shmem_aops
> > flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> > raw: 01fffc000008000c ffffea0000ac4f08 ffff8880a85af890 ffff88800df2ad40
> > raw: 000000000000000f 0000000000000000 00000000ffffffff 0000000000000000
> > page dumped because: non-NULL mapping
> > Modules linked in:
> > CPU: 1 PID: 7586 Comm: udevd Not tainted 5.0.0-rc6-next-20190213 #34
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> > Google 01/01/2011
> > Call Trace:
> >   __dump_stack lib/dump_stack.c:77 [inline]
> >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
> >   free_pages_check mm/page_alloc.c:1023 [inline]
> >   free_pages_prepare mm/page_alloc.c:1113 [inline]
> >   free_pcp_prepare mm/page_alloc.c:1138 [inline]
> >   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
> >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> > name:"memfd:"
> >   release_pages+0x60d/0x1940 mm/swap.c:791
> >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> >   __pagevec_lru_add mm/swap.c:917 [inline]
> >   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
> >   lru_add_drain+0x20/0x60 mm/swap.c:652
> >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> >   __mmput kernel/fork.c:1047 [inline]
> >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> >   exec_mmap fs/exec.c:1046 [inline]
> >   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
> >   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
> >   search_binary_handler fs/exec.c:1656 [inline]
> >   search_binary_handler+0x17f/0x570 fs/exec.c:1634
> >   exec_binprm fs/exec.c:1698 [inline]
> >   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
> >   do_execveat_common fs/exec.c:1865 [inline]
> >   do_execve fs/exec.c:1882 [inline]
> >   __do_sys_execve fs/exec.c:1958 [inline]
> >   __se_sys_execve fs/exec.c:1953 [inline]
> >   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
> >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > RIP: 0033:0x7fc7001ba207
> > Code: Bad RIP value.
> > RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> > RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> > RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> > RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> > R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> > R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> > BUG: Bad page state in process udevd  pfn:2b13c
> > page:ffffea0000ac4f00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xe
> > shmem_aops
> > flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> > raw: 01fffc000008000c ffff8880a85af890 ffff8880a85af890 ffff88800df2ad40
> > raw: 000000000000000e 0000000000000000 00000000ffffffff 0000000000000000
> > page dumped because: non-NULL mapping
> > Modules linked in:
> > CPU: 1 PID: 7586 Comm: udevd Tainted: G    B              
> > 5.0.0-rc6-next-20190213 #34
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> > Google 01/01/2011
> > Call Trace:
> >   __dump_stack lib/dump_stack.c:77 [inline]
> >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> > name:"memfd:"
> >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
> >   free_pages_check mm/page_alloc.c:1023 [inline]
> >   free_pages_prepare mm/page_alloc.c:1113 [inline]
> >   free_pcp_prepare mm/page_alloc.c:1138 [inline]
> >   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
> >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> >   release_pages+0x60d/0x1940 mm/swap.c:791
> >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> >   __pagevec_lru_add mm/swap.c:917 [inline]
> >   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
> >   lru_add_drain+0x20/0x60 mm/swap.c:652
> >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> >   __mmput kernel/fork.c:1047 [inline]
> >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> >   exec_mmap fs/exec.c:1046 [inline]
> >   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
> >   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
> >   search_binary_handler fs/exec.c:1656 [inline]
> >   search_binary_handler+0x17f/0x570 fs/exec.c:1634
> >   exec_binprm fs/exec.c:1698 [inline]
> >   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
> >   do_execveat_common fs/exec.c:1865 [inline]
> >   do_execve fs/exec.c:1882 [inline]
> >   __do_sys_execve fs/exec.c:1958 [inline]
> >   __se_sys_execve fs/exec.c:1953 [inline]
> >   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
> >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > RIP: 0033:0x7fc7001ba207
> > Code: Bad RIP value.
> > RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> > RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> > RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> > RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> > R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> > R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> > 
> > 
> > ---
> > This bug is generated by a bot. It may contain errors.
> > See https://goo.gl/tpsmEJ for more information about syzbot.
> > syzbot engineers can be reached at syzkaller@googlegroups.com.
> > 
> > syzbot will keep track of this bug report. See:
> > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
> > syzbot.
> > syzbot can test patches for this bug, for details see:
> > https://goo.gl/tpsmEJ#testing-patches
> 
> -- 
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/20190213122331.632a4eb1a12b738ef9633855%40linux-foundation.org.
> For more options, visit https://groups.google.com/d/optout.

It's apparently the bug in the io_uring patchset I reported yesterday (well, I
stole it from another open syzbot bug...) and Jens is already planning to fix:
https://marc.info/?l=linux-api&m=155115288114046&w=2.  Reproducer is similar,
and the crash bisects down to the same commit from the io_uring patchset:
"block: implement bio helper to add iter bvec pages to bio".

- Eric

