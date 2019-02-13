Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55008C0044B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:23:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12BB321872
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:23:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12BB321872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A50048E0002; Wed, 13 Feb 2019 15:23:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FF038E0001; Wed, 13 Feb 2019 15:23:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 913998E0002; Wed, 13 Feb 2019 15:23:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 513C98E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:23:35 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a23so2799828pfo.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:23:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6L5271MvBGC1kCIhGNso9+Mdn9ZQA4LIKKB+9zRCbu0=;
        b=j3qrbQT1uwshvFuVfsDBCf+hG/qd2HWScQgzejg+0+pvA7d1VUuYVQsCT8UYSCw96k
         1vCO4WfCF7yafoUEF2duZwyU4TX1IoZnXdVw2iGGH/UuWUO1fxs86nMKnCCN4M0F2iUu
         GN9d/hGPC5nQYt6jRNBN6/ZZGYudLlmD4bEEzbsDHSzO2YCfZabK8RbZKqHOsEnZ+DUp
         NM83H3UcI7gc6xikk0i0dgW/EyBM98p0HwTiqdaqf2s1ydxYBIpozEm2CzLnd9Mfafft
         /4P8AP8BCTWmZOF7McbljHTTr80oAdRpkzYWDSxYidbcELK7FbEPEmPxCzs1yUu6ehBU
         5yOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuY1u8EDDE6Y7Vz+PVhPv6P4eYKpPZp4XoZgQ5HhubO/pz6KIAaa
	3eyqqsMHIqbL9yZVTosku7HSQg09uwYrwnksNz8ix0bdjFu2j0oZOhRHGl0CDxak6YNd1+BhbfL
	kzmrfB9n+Qfv/3O4zccY9VmVD66i75CwIjf3OpKNoLcKN3hahM3D1cq3SGMYWics6HQ==
X-Received: by 2002:a63:5861:: with SMTP id i33mr8083pgm.60.1550089414939;
        Wed, 13 Feb 2019 12:23:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaPq+JD+NfgDzN8dyRx+sFd2CKjBTlp+2Mmw7VepRQRNhebwYlsUlniVvvWMRsncwWFBx/j
X-Received: by 2002:a63:5861:: with SMTP id i33mr8009pgm.60.1550089413765;
        Wed, 13 Feb 2019 12:23:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550089413; cv=none;
        d=google.com; s=arc-20160816;
        b=Ef8cfz2y+TfWdEcu+6zkJlvIuL5ia7KTDq6dlRdKA4ahsyNdwOLj9M89BUl0XXCpYR
         10NAEmIPQJUz5rmhAwovc/3pXzeSXjrfwrxQEYgyt11/qnlk4lPYGhELAd/Q66bRXjRH
         FMpU2dXDjvfmY/im0Rtav25wyDIEMkK8EQjwNp5F7rRBbgqEYEZpmwVsDwdhoGklP6XE
         ejApphC65J5aZpi23UFs73tCIITJtYb6SE3W/nsyV/6/ZApLYM124Ju4oYmIsmEfJO+0
         xrHYu2cbL7jc4+/kVZb5glj9Nbl0uiH4EDDDp3RZiGStfl8ymEfoNdzCuZnTQnZWD7t/
         443g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=6L5271MvBGC1kCIhGNso9+Mdn9ZQA4LIKKB+9zRCbu0=;
        b=iZxtafnSt3zmCgM4At4/5pwI4n86rH/Ml5Bl12QtDwk4A6+dEKOrVu6WbybQevWlEZ
         28TzlrQ0ISlgTZLaBP8mfkE1dmjBr0jAOwkhmX3Jfmc31j/YxMOP/0CPFRbD7XV87vEr
         4pR6u2dPblAGUcFnwb8t+wy4ZHPCdVFZjiy4WoLlnfhX2aAdlSg3lliyuTFTDdl+O+J/
         h37cF33SrcR6k5Fdhx9VQQXi+dnDNRquB9QAU+cUyu7UM+OyzzlyE7VbvEn4bFpdNFv0
         lO7AmyYN48/gFywyKD9fmikQvnX4jYzd1AlNAs6SDinaPuuItR11hYUoNBEmcnZH9+1m
         Uf8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r18si241736pls.115.2019.02.13.12.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 12:23:33 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id C875F118E;
	Wed, 13 Feb 2019 20:23:32 +0000 (UTC)
Date: Wed, 13 Feb 2019 12:23:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com>
Cc: dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mhocko@suse.com, nborisov@suse.com,
 rppt@linux.vnet.ibm.com, shakeelb@google.com,
 syzkaller-bugs@googlegroups.com, vbabka@suse.cz, willy@infradead.org,
 joel@joelfernandes.org, Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: BUG: Bad page state (5)
Message-Id: <20190213122331.632a4eb1a12b738ef9633855@linux-foundation.org>
In-Reply-To: <0000000000006a12bd0581ca4145@google.com>
References: <0000000000006a12bd0581ca4145@google.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2019 09:56:04 -0800 syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com> wrote:

> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    c4f3ef3eb53f Add linux-next specific files for 20190213
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=1130a124c00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=9ec67976eb2df882
> dashboard link: https://syzkaller.appspot.com/bug?extid=2cd2887ea471ed6e6995
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14ecdaa8c00000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12ebe178c00000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com

It looks like a a memfd page was freed with a non-NULL ->mapping.

Joel touched the memfd code with "mm/memfd: add an F_SEAL_FUTURE_WRITE
seal to memfd" but it would be surprising if syzbot tickled that code?


> BUG: Bad page state in process udevd  pfn:472f0
> name:"memfd:"
> page:ffffea00011cbc00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xf
> shmem_aops
> flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> raw: 01fffc000008000c ffffea0000ac4f08 ffff8880a85af890 ffff88800df2ad40
> raw: 000000000000000f 0000000000000000 00000000ffffffff 0000000000000000
> page dumped because: non-NULL mapping
> Modules linked in:
> CPU: 1 PID: 7586 Comm: udevd Not tainted 5.0.0-rc6-next-20190213 #34
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> Google 01/01/2011
> Call Trace:
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
>   bad_page.cold+0xda/0xff mm/page_alloc.c:586
>   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
>   free_pages_check mm/page_alloc.c:1023 [inline]
>   free_pages_prepare mm/page_alloc.c:1113 [inline]
>   free_pcp_prepare mm/page_alloc.c:1138 [inline]
>   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
>   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> name:"memfd:"
>   release_pages+0x60d/0x1940 mm/swap.c:791
>   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
>   __pagevec_lru_add mm/swap.c:917 [inline]
>   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
>   lru_add_drain+0x20/0x60 mm/swap.c:652
>   exit_mmap+0x290/0x530 mm/mmap.c:3134
>   __mmput kernel/fork.c:1047 [inline]
>   mmput+0x15f/0x4c0 kernel/fork.c:1068
>   exec_mmap fs/exec.c:1046 [inline]
>   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
>   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
>   search_binary_handler fs/exec.c:1656 [inline]
>   search_binary_handler+0x17f/0x570 fs/exec.c:1634
>   exec_binprm fs/exec.c:1698 [inline]
>   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
>   do_execveat_common fs/exec.c:1865 [inline]
>   do_execve fs/exec.c:1882 [inline]
>   __do_sys_execve fs/exec.c:1958 [inline]
>   __se_sys_execve fs/exec.c:1953 [inline]
>   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
>   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x7fc7001ba207
> Code: Bad RIP value.
> RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> BUG: Bad page state in process udevd  pfn:2b13c
> page:ffffea0000ac4f00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xe
> shmem_aops
> flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> raw: 01fffc000008000c ffff8880a85af890 ffff8880a85af890 ffff88800df2ad40
> raw: 000000000000000e 0000000000000000 00000000ffffffff 0000000000000000
> page dumped because: non-NULL mapping
> Modules linked in:
> CPU: 1 PID: 7586 Comm: udevd Tainted: G    B              
> 5.0.0-rc6-next-20190213 #34
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> Google 01/01/2011
> Call Trace:
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
>   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> name:"memfd:"
>   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
>   free_pages_check mm/page_alloc.c:1023 [inline]
>   free_pages_prepare mm/page_alloc.c:1113 [inline]
>   free_pcp_prepare mm/page_alloc.c:1138 [inline]
>   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
>   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
>   release_pages+0x60d/0x1940 mm/swap.c:791
>   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
>   __pagevec_lru_add mm/swap.c:917 [inline]
>   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
>   lru_add_drain+0x20/0x60 mm/swap.c:652
>   exit_mmap+0x290/0x530 mm/mmap.c:3134
>   __mmput kernel/fork.c:1047 [inline]
>   mmput+0x15f/0x4c0 kernel/fork.c:1068
>   exec_mmap fs/exec.c:1046 [inline]
>   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
>   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
>   search_binary_handler fs/exec.c:1656 [inline]
>   search_binary_handler+0x17f/0x570 fs/exec.c:1634
>   exec_binprm fs/exec.c:1698 [inline]
>   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
>   do_execveat_common fs/exec.c:1865 [inline]
>   do_execve fs/exec.c:1882 [inline]
>   __do_sys_execve fs/exec.c:1958 [inline]
>   __se_sys_execve fs/exec.c:1953 [inline]
>   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
>   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x7fc7001ba207
> Code: Bad RIP value.
> RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> 
> 
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
> 
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
> syzbot.
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches

