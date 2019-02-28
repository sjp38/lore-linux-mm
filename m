Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A46E6C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:27:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 514DB218CD
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:27:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="NjWKs+Xz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 514DB218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0D6E8E0004; Thu, 28 Feb 2019 13:27:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBD218E0001; Thu, 28 Feb 2019 13:27:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C854E8E0004; Thu, 28 Feb 2019 13:27:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8572A8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:27:26 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id w16so16712185pfn.3
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 10:27:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WUqK+a65oafhxjjTkis0dn7CDeFKthcHh3FbD+BzZqY=;
        b=ZYwdqoiVsI887admzHTprtkssoXx7YK3XOejFX7gZv47xTbYu9RhhBNBUHtJ+fN3x/
         KVQTem5NQtCpVZIOUfjsdo0wUOG196zfJG5mrbFcpddsXpia0uuZ5uqoL0cPWufz+0EC
         xti71s6XVjC+M02ftTdjW2SWxFsNicHKvzOlmpXhpbwsRXeFIHXws2jcApJdaPaTH5rM
         NqkCyhUX0dGMtCJ7Mseut9n4dJMCp/QL22PhHB2Y0MFMjbcoOGVHDHlKwbdbcTERM4rh
         SANEQODcwA+9cN/Gq/M1pak6IKqrfTuP0NHX2OX+m3dsQ/Yk+IXYOAaGaNf104DVQun3
         vmxw==
X-Gm-Message-State: APjAAAVGqkdRdhH0qWLeYaC7bqLVABEkFtQAlif/SVpqj+5Lt2MT/ipG
	9mrgQ5Aa8iCOaDR0RO9xygpcRzHg0VX34wvUr6aUX+xnkSCv9fHPQ28LjhoemLhAeep7f8hqF5/
	xx1XhPLYlcC7w2Uk31ZD4XgSHEfELsBhuV87NqwaONjWw/ip6RENAChp0mjtvZ1Dvrw==
X-Received: by 2002:a63:80c7:: with SMTP id j190mr454291pgd.357.1551378446025;
        Thu, 28 Feb 2019 10:27:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqyynpBFtwc30UV7SR96soLl/xb/fQoy49hZK8T8Djx1hbrQBw7nYtq99+655GcpzwnOaM8e
X-Received: by 2002:a63:80c7:: with SMTP id j190mr454188pgd.357.1551378444393;
        Thu, 28 Feb 2019 10:27:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551378444; cv=none;
        d=google.com; s=arc-20160816;
        b=gvBHizl3u7TFNkvHIjCkJrF2brARbtpBtRsqhWEJXNcuBeUtuNjK0WvmMVLt2ZHvmt
         OvfD/eq6zM8EEKbG+LKxkRV41gSLk45oBS6mk09WWwdfZ1lVHyqwkL3vnD19g1qTBbgN
         teYQs6IPO3sK3theREohVG/zIXvUayqzAsd2Sh3wfLXR9MJBlFngZf3Em/8Pszmm157d
         VSjTy65ZSyORRPzP+CzSFYKIBpr2V7Sf53r8iIuKijTxV1gLALuaYFSaKUMfsJ4+q4iJ
         r8HvnOzzSTdwEvqlg5smSSiDGrJB1PQEolb9Kj6PSLezb5qlOfWGB4euI6ww/zIV00hZ
         WWpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WUqK+a65oafhxjjTkis0dn7CDeFKthcHh3FbD+BzZqY=;
        b=X0g4K+fvESbsyaAj7ahEcHCwG6LQ3Ayz/LR+8C4+R8cOFmw+uF3Nn4NO5e2hJ+DQfs
         oDuPLdCe0rCeekUTyVwM/hssb0MWzYsQV4Y7bljEfXthgiOWMgDQqhSvVWkSmV2YjR/G
         kjtmyDHnCm7GqPTcujs+AaVL4V2oMJ9VM8ZaaKETQrYbzSUXgzLO6Jj+U49xatv0dwoD
         POBhY+gNqEETw/wuNaiKccXLNEpFxOUgnQQ9zK2oqEC0u7c0+Now6nlykVP70MkYCDGP
         4DKUzFBZtQEUvoOJs6TRqOIkITb4KO/SvzmADw58jZKIuoZ4fwVHEvghcx/wXWI/v0XI
         5Z5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NjWKs+Xz;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v23si18325325pgn.542.2019.02.28.10.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 10:27:24 -0800 (PST)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NjWKs+Xz;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sol.localdomain (c-107-3-167-184.hsd1.ca.comcast.net [107.3.167.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8190A218AE;
	Thu, 28 Feb 2019 18:27:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551378444;
	bh=tbCBRoN3tDzBKovQ2Fk0uG/BvJxhK5Af/WJVqe/AhNc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=NjWKs+XzjNsrZet0lcKHuFVwWwPacFUs/D5qoHIy2kIScsvhySkiTRBKZzZPgzq4W
	 Vb8ThseM2Gs6aiGWrK7HLt2PB+JFHbg+vu21KxiPD09jYzPYU8hKBAmiC4c+E0z0n2
	 r3YnZ5BpkQojw1/fXZEWFGhwFkuJzwMUXCXjUQts=
Date: Thu, 28 Feb 2019 10:27:22 -0800
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
Message-ID: <20190228182720.GC663@sol.localdomain>
References: <0000000000006a12bd0581ca4145@google.com>
 <20190213122331.632a4eb1a12b738ef9633855@linux-foundation.org>
 <20190226182129.GA218103@gmail.com>
 <20190227205323.GA186986@gmail.com>
 <CACT4Y+ZK5MrJ3GZ-sxihNpRaun4aMOxkRqmLqQJxYEgD2cnfZQ@mail.gmail.com>
 <20190228075943.GG699@sol.localdomain>
 <CACT4Y+aNnTzD1Q+WxFA9ob-t+NrehL3GYF-e+=U5Z8f5ZQTudg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+aNnTzD1Q+WxFA9ob-t+NrehL3GYF-e+=U5Z8f5ZQTudg@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 10:31:53AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> On Thu, Feb 28, 2019 at 8:59 AM Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > On Thu, Feb 28, 2019 at 07:53:09AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> > > On Wed, Feb 27, 2019 at 9:53 PM Eric Biggers <ebiggers@kernel.org> wrote:
> > > >
> > > > On Tue, Feb 26, 2019 at 10:21:30AM -0800, Eric Biggers wrote:
> > > > > On Wed, Feb 13, 2019 at 12:23:31PM -0800, Andrew Morton wrote:
> > > > > > On Wed, 13 Feb 2019 09:56:04 -0800 syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com> wrote:
> > > > > >
> > > > > > > Hello,
> > > > > > >
> > > > > > > syzbot found the following crash on:
> > > > > > >
> > > > > > > HEAD commit:    c4f3ef3eb53f Add linux-next specific files for 20190213
> > > > > > > git tree:       linux-next
> > > > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=1130a124c00000
> > > > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=9ec67976eb2df882
> > > > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=2cd2887ea471ed6e6995
> > > > > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14ecdaa8c00000
> > > > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12ebe178c00000
> > > > > > >
> > > > > > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > > > > > Reported-by: syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com
> > > > > >
> > > > > > It looks like a a memfd page was freed with a non-NULL ->mapping.
> > > > > >
> > > > > > Joel touched the memfd code with "mm/memfd: add an F_SEAL_FUTURE_WRITE
> > > > > > seal to memfd" but it would be surprising if syzbot tickled that code?
> > > > > >
> > > > > >
> > > > > > > BUG: Bad page state in process udevd  pfn:472f0
> > > > > > > name:"memfd:"
> > > > > > > page:ffffea00011cbc00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xf
> > > > > > > shmem_aops
> > > > > > > flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> > > > > > > raw: 01fffc000008000c ffffea0000ac4f08 ffff8880a85af890 ffff88800df2ad40
> > > > > > > raw: 000000000000000f 0000000000000000 00000000ffffffff 0000000000000000
> > > > > > > page dumped because: non-NULL mapping
> > > > > > > Modules linked in:
> > > > > > > CPU: 1 PID: 7586 Comm: udevd Not tainted 5.0.0-rc6-next-20190213 #34
> > > > > > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > > > > > Google 01/01/2011
> > > > > > > Call Trace:
> > > > > > >   __dump_stack lib/dump_stack.c:77 [inline]
> > > > > > >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> > > > > > >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> > > > > > >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
> > > > > > >   free_pages_check mm/page_alloc.c:1023 [inline]
> > > > > > >   free_pages_prepare mm/page_alloc.c:1113 [inline]
> > > > > > >   free_pcp_prepare mm/page_alloc.c:1138 [inline]
> > > > > > >   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
> > > > > > >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> > > > > > > name:"memfd:"
> > > > > > >   release_pages+0x60d/0x1940 mm/swap.c:791
> > > > > > >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> > > > > > >   __pagevec_lru_add mm/swap.c:917 [inline]
> > > > > > >   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
> > > > > > >   lru_add_drain+0x20/0x60 mm/swap.c:652
> > > > > > >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> > > > > > >   __mmput kernel/fork.c:1047 [inline]
> > > > > > >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> > > > > > >   exec_mmap fs/exec.c:1046 [inline]
> > > > > > >   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
> > > > > > >   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
> > > > > > >   search_binary_handler fs/exec.c:1656 [inline]
> > > > > > >   search_binary_handler+0x17f/0x570 fs/exec.c:1634
> > > > > > >   exec_binprm fs/exec.c:1698 [inline]
> > > > > > >   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
> > > > > > >   do_execveat_common fs/exec.c:1865 [inline]
> > > > > > >   do_execve fs/exec.c:1882 [inline]
> > > > > > >   __do_sys_execve fs/exec.c:1958 [inline]
> > > > > > >   __se_sys_execve fs/exec.c:1953 [inline]
> > > > > > >   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
> > > > > > >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> > > > > > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > > > > RIP: 0033:0x7fc7001ba207
> > > > > > > Code: Bad RIP value.
> > > > > > > RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> > > > > > > RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> > > > > > > RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> > > > > > > RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> > > > > > > R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> > > > > > > R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> > > > > > > BUG: Bad page state in process udevd  pfn:2b13c
> > > > > > > page:ffffea0000ac4f00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xe
> > > > > > > shmem_aops
> > > > > > > flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
> > > > > > > raw: 01fffc000008000c ffff8880a85af890 ffff8880a85af890 ffff88800df2ad40
> > > > > > > raw: 000000000000000e 0000000000000000 00000000ffffffff 0000000000000000
> > > > > > > page dumped because: non-NULL mapping
> > > > > > > Modules linked in:
> > > > > > > CPU: 1 PID: 7586 Comm: udevd Tainted: G    B
> > > > > > > 5.0.0-rc6-next-20190213 #34
> > > > > > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > > > > > Google 01/01/2011
> > > > > > > Call Trace:
> > > > > > >   __dump_stack lib/dump_stack.c:77 [inline]
> > > > > > >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> > > > > > >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> > > > > > > name:"memfd:"
> > > > > > >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
> > > > > > >   free_pages_check mm/page_alloc.c:1023 [inline]
> > > > > > >   free_pages_prepare mm/page_alloc.c:1113 [inline]
> > > > > > >   free_pcp_prepare mm/page_alloc.c:1138 [inline]
> > > > > > >   free_unref_page_prepare mm/page_alloc.c:2991 [inline]
> > > > > > >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
> > > > > > >   release_pages+0x60d/0x1940 mm/swap.c:791
> > > > > > >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> > > > > > >   __pagevec_lru_add mm/swap.c:917 [inline]
> > > > > > >   lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
> > > > > > >   lru_add_drain+0x20/0x60 mm/swap.c:652
> > > > > > >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> > > > > > >   __mmput kernel/fork.c:1047 [inline]
> > > > > > >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> > > > > > >   exec_mmap fs/exec.c:1046 [inline]
> > > > > > >   flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
> > > > > > >   load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
> > > > > > >   search_binary_handler fs/exec.c:1656 [inline]
> > > > > > >   search_binary_handler+0x17f/0x570 fs/exec.c:1634
> > > > > > >   exec_binprm fs/exec.c:1698 [inline]
> > > > > > >   __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
> > > > > > >   do_execveat_common fs/exec.c:1865 [inline]
> > > > > > >   do_execve fs/exec.c:1882 [inline]
> > > > > > >   __do_sys_execve fs/exec.c:1958 [inline]
> > > > > > >   __se_sys_execve fs/exec.c:1953 [inline]
> > > > > > >   __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
> > > > > > >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> > > > > > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > > > > RIP: 0033:0x7fc7001ba207
> > > > > > > Code: Bad RIP value.
> > > > > > > RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
> > > > > > > RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
> > > > > > > RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
> > > > > > > RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
> > > > > > > R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
> > > > > > > R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
> > > > > > >
> > > > > > >
> > > > > > > ---
> > > > > > > This bug is generated by a bot. It may contain errors.
> > > > > > > See https://goo.gl/tpsmEJ for more information about syzbot.
> > > > > > > syzbot engineers can be reached at syzkaller@googlegroups.com.
> > > > > > >
> > > > > > > syzbot will keep track of this bug report. See:
> > > > > > > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> > > > > > > syzbot.
> > > > > > > syzbot can test patches for this bug, for details see:
> > > > > > > https://goo.gl/tpsmEJ#testing-patches
> > > > > >
> > > > >
> > > > > It's apparently the bug in the io_uring patchset I reported yesterday (well, I
> > > > > stole it from another open syzbot bug...) and Jens is already planning to fix:
> > > > > https://marc.info/?l=linux-api&m=155115288114046&w=2.  Reproducer is similar,
> > > > > and the crash bisects down to the same commit from the io_uring patchset:
> > > > > "block: implement bio helper to add iter bvec pages to bio".
> > > > >
> > > >
> > > > Fixed in next-20190227.  The fix was folded into "block: implement bio helper to
> > > > add iter bvec pages to bio".  Telling syzbot to invalidate this bug report:
> > > >
> > > > #syz invalid
> > >
> > > Was this discovered separately? We could also add Reported-by (or
> > > Tested-by) tag to the commit.
> > >
> >
> > My report was based on a crash from the syzbot dashboard.  However, there's no
> > fixing commit, as the fix was folded into the original patch.  I.e. the mainline
> > git history (if/when the io_uring stuff is actually merged) won't show the bug
> > ever being introduced.  Thus Reported-by isn't appropriate, and I used '#syz
> > invalid' instead of '#syz fix'.  Nor did syzbot specifically test the new
> > version of the patch beyond fuzzing the next day's linux-next...  So while I
> > personally might have added an informal note in the commit message, I don't
> > think those formal tags make sense for folded-in linux-next fixes like this.
> 
> This was discussed before and we come to conclusion that Tested-by is
> a reasonable thing in such case:
> https://groups.google.com/d/msg/syzkaller-bugs/xiSF9GdiikU/uBoyYyf3AQAJ
> It did test the patch since it found the bug. Tested-by does not
> necessary mean that the person did all possible kinds of testing on
> all versions, right?
> 

syzbot didn't actually run the reproducer on the new version of the patch; I
did.  And I have high standards so I wouldn't offer my Tested-by just based on
that, as the patch could still have many other problems which I did not test...

Anyway, I don't think you will have much success trying to make people record
the bug fix history of every linux-next patch.  In some branches that go into
linux-next, patches are regularly merged, split, replaced, or dropped.  Also
developers may use a free-form sentence explaining that a fix was folded in, as
e.g. using Reported-by incorrectly implies that the patch fixes an existing bug.

So I think that for linux-next people will sometimes just have to update the
syzbot bug statuses manually.

- Eric

