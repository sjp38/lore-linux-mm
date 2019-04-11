Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0D99C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 19:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 349FB2073F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 19:54:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ptn/5dxn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 349FB2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 906D06B0269; Thu, 11 Apr 2019 15:54:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B4E26B026A; Thu, 11 Apr 2019 15:54:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A3CE6B026B; Thu, 11 Apr 2019 15:54:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 411E16B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 15:54:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so5004083pgf.22
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:54:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=plfO4IyDLrh8XCsOuOTE9mmlQhKOghOaXoY6UTy4GdQ=;
        b=uDOqCrmqw8yCjl3rkSLH2rekYSNtCtFEdtsd+SR3v3lzEx+bZ5J/Y47Y7PRCoeQo4K
         H7e/yp1aOIbYzI7Gf2eEnKrps+AQZSw5/24E2+tr+01/YpHFzrccQg9jlng7jIncQAT4
         KOVGJDD/4VmKZ7xOIXrdhUC0pg34bDcG5cXKWIsjKadiOZCg7K7X+kA7oGL3/DzJ4WI/
         nN/lB1RW1rR/AznTPBYJ6L/R4c0RZ8o15Dtv6LreivJdEcUmEEMb2gWfDNU+ugfVBios
         xBem1sV/8ePjEmtBUWZt6+xmd0o7QqfHNaFRWq8ItLa/cRkq6BX1qR3Ww3p8Za7RfhrT
         obEA==
X-Gm-Message-State: APjAAAXXDyM0CZRJrDgVP3PL1zRPcweBGAeIdhJoESFT3Riai1lQflAX
	zHFXSQfHpufvru8ZhT/wq69mFYnQWgNRKDtlGG83Jxax1PGVyrL+ZZtxDubR8jpohCZNmxg6vK6
	NFsbUu7QjQmhK7uZMLmA8U55W+9hEUaodxoKXkntwVY7JBK1geqUc0XHmR7zI3/Nixg==
X-Received: by 2002:a65:62c9:: with SMTP id m9mr45527757pgv.309.1555012472532;
        Thu, 11 Apr 2019 12:54:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz99m72Zt3PhmZ003467kZCx40qH6KMe6DMZpfXHMJK+kZlD3oj1hzyL3oaP5ktrEFbfaSA
X-Received: by 2002:a65:62c9:: with SMTP id m9mr45527672pgv.309.1555012471385;
        Thu, 11 Apr 2019 12:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555012471; cv=none;
        d=google.com; s=arc-20160816;
        b=SIchnugesJ5hRW3SiaYxpBAAEHrrnVEvqkQpK5FnnJYgIU62SdOGMVNV3UHgpRknqi
         rqPxLe6HDNgzne5yGhRIN2NZf0KIjy2YozVHo+07avJtiylv7MgwHFWwCV98tjEa1pyz
         KUKyLLZsbQAMsSs9zPoP21eEjD9e+gyzEc6amnoYkCi2EhNLgs2WitY0sX2y6iluEnhU
         +iw+bP7oTh7vSNPB78ZAdOeR89JWT8k0N52L6bF75LwzxB8CCBTgOXERcnVDEXF6pRn5
         isq8OD6Tg+VKNx6ILoB/kVSOg4bezXF44apDYX8rwl/OoJ/fvBpT4EMUwcVoWzGRtzrb
         +Dcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=plfO4IyDLrh8XCsOuOTE9mmlQhKOghOaXoY6UTy4GdQ=;
        b=W0mNPMiR/7C+HfiafeTDLnuqtznT3AlLvhNXTaUSagdTqCMWKa7xrR2IUh6rqcrfwn
         8UvViTK6RVu45J10txGygn02kfn/Za7mwxsvOeNnYFgbyc7OqCzDLr9w4H2gyHiz4cDP
         CAeQGKRmL5JftVd+SGxDUpSiNIJpyIFRSHzVx5nuyxpq8vsu8/o87AUX7Q8HF5jkYJx8
         A8omXCcSp7fw35Ce/2IyeTlyyeBcRAqNHZKny4Gl7TkFpbI7/ygU+krww1p2pSYEJEpz
         btwOmTMKTLgTqSsy9GIMEO3HL3KJjIfcTUKHwMwXOkbkV69TcR4w8gXlUgPA0p2GCjio
         hJYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ptn/5dxn";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k66si35224669pgc.247.2019.04.11.12.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 12:54:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ptn/5dxn";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=plfO4IyDLrh8XCsOuOTE9mmlQhKOghOaXoY6UTy4GdQ=; b=Ptn/5dxnB/kkzSc9Gd1nd/D35
	VjOwgzVbjo4hTs/sHVDbhkrD/fyqtp7eRzJioX1PFZqNv54hpayr2sVsbkhmm/BuF5E+FwrKwGQCI
	oDR1dpOE5b8OqyZnoHSy3zi0tsq3M4moDFEofG+ElR9pzPI71kcVw4/E0WoSIDsbDn/owPd4womCe
	U9hdtqzVhNYSPQJ9+QhBA/VmV2Yi7wiOkgiCcj+RFzn3mADmfLgu7ksx+hByHgxKVgogcxwVHNCNK
	caWgGWJAm0fpCqY8tAwFvhvvJPAe7W09Q7IDn1mtKh1LsaEXKs/Gf79+WUGmCK3yg1I5pOgda9xW9
	a17zQdg+A==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hEfmE-0003ys-Fc; Thu, 11 Apr 2019 19:54:26 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7B1E929AB9D56; Thu, 11 Apr 2019 21:54:24 +0200 (CEST)
Date: Thu, 11 Apr 2019 21:54:24 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: kernel test robot <lkp@intel.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Message-ID: <20190411195424.GL14281@hirez.programming.kicks-ass.net>
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
 <20190411193906.GA12232@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411193906.GA12232@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 09:39:06PM +0200, Peter Zijlstra wrote:
> I think this bisect is bad. If you look at your own logs this patch
> merely changes the failure, but doesn't make it go away.
> 
> Before this patch (in fact, before tip/core/mm entirely) the errror
> reads like the below, which suggests there is memory corruption
> somewhere, and the fingered patch just makes it trigger differently.
> 
> It would be very good to find the source of this corruption, but I'm
> fairly certain it is not here.

I went back to v4.20 to try and find a time when the below error did not
occur, but even that reliably triggers the warning.

> [   10.273617] rodata_test: all tests were successful
> [   10.275015] x86/mm: Checking user space page tables
> [   10.295444] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [   10.296334] Run /init as init process
> [   10.301465] ==================================================================
> [   10.302460] BUG: KASAN: stack-out-of-bounds in __unwind_start+0x7e/0x4fe
> [   10.303355] Write of size 88 at addr ffff8880191efa28 by task init/1
> [   10.304241]
> [   10.304455] CPU: 0 PID: 1 Comm: init Not tainted 5.1.0-rc4-00288-ga131d61b43e0-dirty #10
> [   10.305542] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   10.306641] Call Trace:
> [   10.306990]  print_address_description+0x9d/0x26b
> [   10.307654]  ? __unwind_start+0x7e/0x4fe
> [   10.308222]  ? __unwind_start+0x7e/0x4fe
> [   10.308755]  __kasan_report+0x145/0x18a
> [   10.309266]  ? __unwind_start+0x7e/0x4fe
> [   10.309823]  kasan_report+0xe/0x12
> [   10.310273]  memset+0x1f/0x31
> [   10.310703]  __unwind_start+0x7e/0x4fe
> [   10.311223]  ? unwind_next_frame+0x10a9/0x10a9
> [   10.311839]  ? native_flush_tlb_one_user+0x54/0x95
> [   10.312504]  ? kasan_unpoison_shadow+0xf/0x2e
> [   10.313090]  __save_stack_trace+0x65/0xe7
> [   10.313667]  ? trace_irq_enable_rcuidle+0x21/0xf5
> [   10.314284]  ? tracer_hardirqs_on+0xb/0x1b
> [   10.314830]  ? trace_hardirqs_on+0x2c/0x37
> [   10.315369]  save_stack+0x32/0xa3
> [   10.315842]  ? __put_compound_page+0x91/0x91
> [   10.316458]  ? preempt_latency_start+0x22/0x68
> [   10.317052]  ? free_swap_cache+0x51/0xd5
> [   10.317586]  ? tlb_flush_mmu_free+0x31/0xca
> [   10.318140]  ? arch_tlb_finish_mmu+0x8c/0x112
> [   10.318759]  ? tlb_finish_mmu+0xc7/0xd6
> [   10.319298]  ? unmap_region+0x275/0x2b9
> [   10.319835]  ? special_mapping_fault+0x26d/0x26d
> [   10.320448]  ? trace_irq_disable_rcuidle+0x21/0xf5
> [   10.321085]  __kasan_slab_free+0xd3/0xf4
> [   10.321623]  ? remove_vma+0xdf/0xe7
> [   10.322105]  kmem_cache_free+0x4e/0xca
> [   10.322600]  remove_vma+0xdf/0xe7
> [   10.323038]  __do_munmap+0x72c/0x75e
> [   10.323514]  __vm_munmap+0xd0/0x135
> [   10.323980]  ? __x64_sys_brk+0x40e/0x40e
> [   10.324496]  ? trace_irq_disable_rcuidle+0x21/0xf5
> [   10.325160]  __x64_sys_munmap+0x6a/0x6f
> [   10.325670]  do_syscall_64+0x3f0/0x462
> [   10.326162]  ? syscall_return_slowpath+0x154/0x154
> [   10.326810]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
> [   10.327485]  ? trace_irq_disable_rcuidle+0x21/0xf5
> [   10.328153]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
> [   10.328873]  ? trace_hardirqs_off_caller+0x3e/0x40
> [   10.329505]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [   10.330162]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [   10.330830] RIP: 0033:0x7efc4d707457
> [   10.331306] Code: f0 ff ff 73 01 c3 48 8d 0d 5a be 20 00 31 d2 48 29 c2 89 11 48 83 c8 ff eb eb 90 90 90 90 90 90 90 90 90 b8 0b 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8d 0d 2d be 20 00 31 d2 48 29 c2 89
> [   10.333711] RSP: 002b:00007fff973da398 EFLAGS: 00000203 ORIG_RAX: 000000000000000b
> [   10.334728] RAX: ffffffffffffffda RBX: 00007efc4d9132c8 RCX: 00007efc4d707457
> [   10.335670] RDX: 0000000000000000 RSI: 0000000000001d67 RDI: 00007efc4d90d000
> [   10.336596] RBP: 00007fff973da4f0 R08: 0000000000000007 R09: 00000000ffffffff
> [   10.337512] R10: 0000000000000000 R11: 0000000000000203 R12: 000000073dd74283
> [   10.338457] R13: 000000073db1ab4f R14: 00007efc4d909700 R15: 00007efc4d9132c8
> [   10.339373]
> [   10.339585] The buggy address belongs to the page:
> [   10.340224] page:ffff88801de82c48 count:0 mapcount:0 mapping:0000000000000000 index:0x0
> [   10.341338] flags: 0x680000000000()
> [   10.341832] raw: 0000680000000000 ffff88801de82c50 ffff88801de82c50 0000000000000000
> [   10.342846] raw: 0000000000000000 0000000000000000 00000000ffffffff
> [   10.343679] page dumped because: kasan: bad access detected
> [   10.344415]
> [   10.344629] Memory state around the buggy address:
> [   10.345254]  ffff8880191ef900: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> [   10.346245]  ffff8880191ef980: 00 00 f1 f1 f1 f1 00 f2 f2 f2 00 00 00 00 00 00
> [   10.347217] >ffff8880191efa00: 00 00 00 00 00 f2 f2 f2 00 00 00 00 00 00 00 00
> [   10.348152]                                   ^
> [   10.348755]  ffff8880191efa80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> [   10.349698]  ffff8880191efb00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> [   10.350650] ==================================================================

