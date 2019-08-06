Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C71C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:58:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEBC020684
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:58:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sv03h4En"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEBC020684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5913E6B0003; Tue,  6 Aug 2019 19:58:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51B3F6B0006; Tue,  6 Aug 2019 19:58:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 393FA6B0007; Tue,  6 Aug 2019 19:58:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 048AD6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:58:27 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j12so49210009pll.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:58:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wMdmOR08Oikb8ikVaqlyv4A1JGg1JQtorE+1XZo6ZFI=;
        b=EyU019lcIbWOzfJ8KiKU4gtV2oh+nhQV/+WFim2epFjzm+tQqcnurnftQGfNDvztr3
         F6jKJ5S3DJkt5RRia+9Ixo3fHsTHvhWeHqp3RoVrU/fIpOpd7FtgUYv59yhaffxcX5gb
         BorK+Dt55vcjO70ojy3pkQKETet67kC1vUi1PmkdCN9ak6ChIDNihTJcByVJa8sE140U
         /gEMaibkOac7bHYI/0IPousjL0JIrRWIP/hiVfabrNr3zGRuXPWD13Lk+kz+6/EiMwgb
         4qlDpWJ/G61yz4AMncZoHnlMmlHsuhP1lx0bAgynbjSD+M+m5yiyMg2gyrAOkAYk4b8s
         nt3Q==
X-Gm-Message-State: APjAAAUHkVLcURET0TNF3tNKje2x89GrtWujSRRfpmDo1p5AWTM2co46
	Udgk5PRrE+yedwh1IweEbklE8sHQrhSFt6bV5LjI5Y7mlZmp6aI8nTJbANt6trlzgc7bJs1yuGL
	uJG623K6YEleKjl4LWKRCXLGrAfH0L1MbGnKQyj6U/nNg3hRzCTHB4MqKVnE/gUIY/w==
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr5775795plb.30.1565135906597;
        Tue, 06 Aug 2019 16:58:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1C3FOddVIQM7+MumCPVRtAlvIExeJNNK1tsrF3Z7Yc7HUe609NXRHD8XrS9xqhnupZxy6
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr5775755plb.30.1565135905755;
        Tue, 06 Aug 2019 16:58:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565135905; cv=none;
        d=google.com; s=arc-20160816;
        b=lVBru9criIEzl0FE7P/5r6/2e06zZLvC5/HWuTwzuiib2Pq6nvgjVacaM8wnkraOda
         na5qm9svPNxXPmDSiSrPU2aKX1l3WDcRLu8jpyolI8aVe/FUILxzDYvLsPX2TM6WIIF8
         6fiYes9XPL9hywKsk4ByNOZIK97WTfgov7t223ZSx3J5XzIIFFA3U5x9ZYuK6ts4W6Rq
         /kg5xPh6B+1fhtF+rb7vgv93egpS8WXBrlJFRbRTtFSFqVhAoBxcNTht3Oima7vmSfj+
         Tx4LDHSBtdt4cxXVvfZKS4rNcKemrYZKVLBQ6VuTHn915dwl6B0dkUzSfwTMSi5MOmBZ
         26AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wMdmOR08Oikb8ikVaqlyv4A1JGg1JQtorE+1XZo6ZFI=;
        b=nqyR4d/8aRIgKy4wdMUCmQboM8sE6kMvCcOMKVF8Z7fhFrOWkn+0d4XQVFLQJsqm0N
         WMYXIk5xphruwH5gU23m8zWxJF9HT7YLNs/ta4+4TruizN1ULhZ5iJZX1HT6Qkk3ccEH
         iFO+GId/0uF8jXJ7s7xkmhepKG+T3xp2EjMA5YQJiRzyEaepC1r03hw2yEe02NatcmDr
         FohipczCuU2zmUX8HIIwhmKmrTgGgDMYoGnMOOrwTE2u4/Ght7fzUivjdlbexWSJ+dzT
         KwFDLJB8F87DXEQxmb/vkE7dt2ZSRwdkGvPbYCxsl9PcqZ51DOhed9GCNAJXN20tiXHU
         uPKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sv03h4En;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c18si15608282pjo.105.2019.08.06.16.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 16:58:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sv03h4En;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 96CCD20663;
	Tue,  6 Aug 2019 23:58:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565135905;
	bh=j/RvlO/MM/u062VCfMQ2ZMvgSxU6N459yDU0a9QHEGM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Sv03h4En6sHUvjYMfXRk7QmI1g/wUlUCsu+aLDz8UlUIF+0+cyQ6Di38j7Nnhrysv
	 4SOmjpm0qbcj0ZtINtXe+NNaZM+B40VBZiQd0Ldi81tCJ4rI86C8d8hc1svMxl0Ha0
	 p2uze6hxnY52pKINnpq4ffN6GSw4LSF0BCnJxCUg=
Date: Tue, 6 Aug 2019 16:58:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ard Biesheuvel
 <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov
 <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, James Morse
 <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWU=?= Glisse
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas
 Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Mark
 Rutland <Mark.Rutland@arm.com>, "Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v10 20/22] x86: mm: Convert dump_pagetables to use
 walk_page_range
Message-Id: <20190806165823.3f735b45a7c4163aca20a767@linux-foundation.org>
In-Reply-To: <20190731154603.41797-21-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
	<20190731154603.41797-21-steven.price@arm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2019 16:46:01 +0100 Steven Price <steven.price@arm.com> wrote:

> Make use of the new functionality in walk_page_range to remove the
> arch page walking code and use the generic code to walk the page tables.
> 
> The effective permissions are passed down the chain using new fields
> in struct pg_state.
> 
> The KASAN optimisation is implemented by including test_p?d callbacks
> which can decide to skip an entire tree of entries
> 
> ...
>
> +static const struct ptdump_range ptdump_ranges[] = {
> +#ifdef CONFIG_X86_64
>  
> -#define pgd_large(a) (pgtable_l5_enabled() ? pgd_large(a) : p4d_large(__p4d(pgd_val(a))))
> -#define pgd_none(a)  (pgtable_l5_enabled() ? pgd_none(a) : p4d_none(__p4d(pgd_val(a))))
> +#define normalize_addr_shift (64 - (__VIRTUAL_MASK_SHIFT + 1))
> +#define normalize_addr(u) ((signed long)(u << normalize_addr_shift) \
> +				>> normalize_addr_shift)
>  
> -static inline bool is_hypervisor_range(int idx)
> -{
> -#ifdef CONFIG_X86_64
> -	/*
> -	 * A hole in the beginning of kernel address space reserved
> -	 * for a hypervisor.
> -	 */
> -	return	(idx >= pgd_index(GUARD_HOLE_BASE_ADDR)) &&
> -		(idx <  pgd_index(GUARD_HOLE_END_ADDR));
> +	{0, PTRS_PER_PGD * PGD_LEVEL_MULT / 2},
> +	{normalize_addr(PTRS_PER_PGD * PGD_LEVEL_MULT / 2), ~0UL},

This blows up because PGD_LEVEL_MULT is sometimes not a constant.

x86_64 allmodconfig:

In file included from ./arch/x86/include/asm/pgtable_types.h:249:0,
                 from ./arch/x86/include/asm/paravirt_types.h:45,
                 from ./arch/x86/include/asm/ptrace.h:94,
                 from ./arch/x86/include/asm/math_emu.h:5,
                 from ./arch/x86/include/asm/processor.h:12,
                 from ./arch/x86/include/asm/cpufeature.h:5,
                 from ./arch/x86/include/asm/thread_info.h:53,
                 from ./include/linux/thread_info.h:38,
                 from ./arch/x86/include/asm/preempt.h:7,
                 from ./include/linux/preempt.h:78,
                 from ./include/linux/spinlock.h:51,
                 from ./include/linux/wait.h:9,
                 from ./include/linux/wait_bit.h:8,
                 from ./include/linux/fs.h:6,
                 from ./include/linux/debugfs.h:15,
                 from arch/x86/mm/dump_pagetables.c:11:
./arch/x86/include/asm/pgtable_64_types.h:56:22: error: initializer element is not constant
 #define PTRS_PER_PGD 512
                      ^
arch/x86/mm/dump_pagetables.c:363:6: note: in expansion of macro ‘PTRS_PER_PGD’
  {0, PTRS_PER_PGD * PGD_LEVEL_MULT / 2},
      ^~~~~~~~~~~~
./arch/x86/include/asm/pgtable_64_types.h:56:22: note: (near initialization for ‘ptdump_ranges[0].end’)
 #define PTRS_PER_PGD 512
                      ^
arch/x86/mm/dump_pagetables.c:363:6: note: in expansion of macro ‘PTRS_PER_PGD’
  {0, PTRS_PER_PGD * PGD_LEVEL_MULT / 2},
      ^~~~~~~~~~~~
arch/x86/mm/dump_pagetables.c:360:27: error: initializer element is not constant
 #define normalize_addr(u) ((signed long)(u << normalize_addr_shift) \
                           ^
arch/x86/mm/dump_pagetables.c:364:3: note: in expansion of macro ‘normalize_addr’
  {normalize_addr(PTRS_PER_PGD * PGD_LEVEL_MULT / 2), ~0UL},
   ^~~~~~~~~~~~~~
arch/x86/mm/dump_pagetables.c:360:27: note: (near initialization for ‘ptdump_ranges[1].start’)
 #define normalize_addr(u) ((signed long)(u << normalize_addr_shift) \
                           ^
arch/x86/mm/dump_pagetables.c:364:3: note: in expansion of macro ‘normalize_addr’
  {normalize_addr(PTRS_PER_PGD * PGD_LEVEL_MULT / 2), ~0UL},

I don't know what to do about this so I'll drop the series.

