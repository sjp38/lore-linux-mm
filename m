Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D378C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:29:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EBB120643
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:29:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1pdY9JKW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EBB120643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B02656B0008; Thu, 18 Apr 2019 14:29:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8A326B000C; Thu, 18 Apr 2019 14:29:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92EFE6B000D; Thu, 18 Apr 2019 14:29:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 553906B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:29:29 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s19so1953721plp.6
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:29:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:subject:in-reply-to:references:message-id;
        bh=4IwPQs7+tWqTBeINo7em/WUJgXV/TTzNcedECp74YJU=;
        b=JOLvc1ONDqhm2WHwOR8ax/5iKpn+SJiIKoH0idjcsW0jKEA+0RcDHeJQ3+VuKKJYnO
         DBP16htULteauZ78dpzYbb3B+gssV5gKnHNnYMznwwffjuGdv4M41337s2IkmYnuk7zV
         gwEbKWnNtdb9zU2P1NR8F9kVUp6X4XyOqXEqNCJXIBzVILzWIQiV1c+kz0XenlYBIwi2
         028BP5JPH8j1FSYg88HGDiUKRVtGLJqCRplJ4FlnhTij9ZeU47Uuav2yNqGe8UfaqGUN
         hwQOZEwvPLpFo2YwonNFCouKwmlsWY0itTTMT1qjxjq1MFKj6PHSOIeLpZFQh/05KO2H
         bgEQ==
X-Gm-Message-State: APjAAAUBHvOeUmjPEewNbRLxOcLPJ2doxUNZqFbu2+nY1UgFT1+W8NQQ
	aE5pscO3tKZQsBvmkZ6h42kkhr/8rmq+py4Cy1jO1SBj6UUGKJVzI0F5xaLKnYOUQZZAd37VFJp
	wI76RDmAbEXSTRoktxftXCHVE4J7GL9Cvw1iBacYoU/66+mB6Tfy2vRd7TKgy0yFzpQ==
X-Received: by 2002:a63:c34c:: with SMTP id e12mr91242143pgd.279.1555612168962;
        Thu, 18 Apr 2019 11:29:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznuwckmfNTHxof804szwbupvTA/6aLOOtZQr6w0Dep2WszLYXAFJW66Thtl7Y613aI9Xug
X-Received: by 2002:a63:c34c:: with SMTP id e12mr91242094pgd.279.1555612168232;
        Thu, 18 Apr 2019 11:29:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555612168; cv=none;
        d=google.com; s=arc-20160816;
        b=z546YTj20XUmSg/2J8JSyz70vqxMBMTjceaJIQfN9LHoOE3aaA2dlXjs1k1hh/sUrr
         ZV5W2Exhp3E79MmnP/1xLn4LAVnSO99SdDQPDT6bciTzDYNZ4uqfuYFx0b7Q+sGv6cYS
         QFWAxsVY/uwbG4h0O6j+W4e/ydx4BGSZQOeZg0zNFn9y/bj0g5Q37xjiJRvTd8PDIp9y
         +Dk182mthezdEFH0qTHpC7nnhRdUAHhjsXT0xOoknyNtsw33Bk8DVhDOPHbRpdHijguE
         99+v0q1c2ReOGXRNGu7JqfamMgvYURVxAyVYxvmHqx010bWOXFfJpGLnvnAymNLZr5SG
         BIdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :to:to:to:from:date:dkim-signature;
        bh=4IwPQs7+tWqTBeINo7em/WUJgXV/TTzNcedECp74YJU=;
        b=b2QmPSJbjOii6ldB2sXpLyka7RrNrAm5XLfFaQh+dwSMvTIrnGv8X/McAyoFmtqCyW
         7qmZL6/R/o301IELlcFqkIYNQloJCqEvWJKu6UjBtEFZNOHUV5a5pc4sOMyRHOA+68BD
         6e/PBk81TlqYbTvGPsjTeNBKG6UJ6W2rv+xzSEWPHDkd+h3fIob9TMtLudn3EP8rOYHA
         jLhFvyJgQfTrm0b+qj1G2/b1kARONcH8L14XpNBV+HECwNDWmvmcHx7+c+jtZWoWbUG5
         wjKJPAMVEackjb8lW3ktMDNzFKi36M5PbsUxDXyVlREww409ZNKpMxGm7CN5DVdj41mf
         pcaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1pdY9JKW;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f11si2594557pgf.406.2019.04.18.11.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 11:29:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1pdY9JKW;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A78AB217D7;
	Thu, 18 Apr 2019 18:29:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555612167;
	bh=rpspHx+PrMhUlp/JN2InCHYxpUdbfr/lUCvq05nBYZA=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:In-Reply-To:
	 References:From;
	b=1pdY9JKW6CU6v5psGDqz2oKEQnlENA4V/83ts6RvmelO+LpnmXTTCzcuar9IiiKPs
	 a654PdO+R0443Gja1SilyK5MKAqNEwkLL0ld2VfI1HOdKRsTjv/6csEpsxXZlliP7u
	 i72GEurCa+7MTtxRS4BGiOosOHtnfpu/F/R8QfW8=
Date: Thu, 18 Apr 2019 18:29:26 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   tip-bot for Dave Hansen <tipbot@zytor.com>
To:     linux-tip-commits@vger.kernel.org
Cc:     dave.hansen@linux.intel.com, tglx@linutronix.de, mhocko@suse.com,
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: stable@vger.kernel.org
Cc: stable@vger.kernel.org
Subject: Re: [tip:x86/urgent] x86/mpx: Fix recursive munmap() corruption
In-Reply-To: <tip-508b8482ea2227ba8695d1cf8311166a455c2ae0@git.kernel.org>
References: <tip-508b8482ea2227ba8695d1cf8311166a455c2ae0@git.kernel.org>
Message-Id: <20190418182927.A78AB217D7@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 1de4fa14ee25 x86, mpx: Cleanup unused bound tables.

The bot has tested the following trees: v5.0.8, v4.19.35, v4.14.112, v4.9.169, v4.4.178.

v5.0.8: Build OK!
v4.19.35: Failed to apply! Possible dependencies:
    dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")

v4.14.112: Failed to apply! Possible dependencies:
    dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")

v4.9.169: Failed to apply! Possible dependencies:
    010426079ec1 ("sched/headers: Prepare for new header dependencies before moving more code to <linux/sched/mm.h>")
    1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for 32-bit mmap()")
    39bc88e5e38e ("arm64: Disable TTBR0_EL1 during normal kernel execution")
    3f07c0144132 ("sched/headers: Prepare for new header dependencies before moving code to <linux/sched/signal.h>")
    44b04912fa72 ("x86/mpx: Do not allow MPX if we have mappings above 47-bit")
    6a0b41d1e23d ("x86/mm: Introduce arch_rnd() to compute 32/64 mmap random base")
    7c0f6ba682b9 ("Replace <asm/uaccess.h> with <linux/uaccess.h> globally")
    8f3e474f3cea ("x86/mm: Add task_size parameter to mmap_base()")
    9cf09d68b89a ("arm64: xen: Enable user access before a privcmd hvc call")
    bd38967d406f ("arm64: Factor out PAN enabling/disabling into separate uaccess_* macros")
    e13b73dd9c80 ("x86/hugetlb: Adjust to the new native/compat mmap bases")

v4.4.178: Failed to apply! Possible dependencies:
    1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for 32-bit mmap()")
    2b5e869ecfcb ("MIPS: ELF: Interpret the NAN2008 file header flag")
    2ed02dd415ae ("MIPS: Use a union to access the ELF file header")
    44b04912fa72 ("x86/mpx: Do not allow MPX if we have mappings above 47-bit")
    5fa393c85719 ("MIPS: Break down cacheops.h definitions")
    694977006a7b ("MIPS: Use enums to make asm/pgtable-bits.h readable")
    745f35587846 ("MIPS: mm: Unify pte_page definition")
    780602d740fc ("MIPS: mm: Standardise on _PAGE_NO_READ, drop _PAGE_READ")
    7939469da29a ("MIPS64: signal: Fix o32 sigaction syscall")
    7b2cb64f91f2 ("MIPS: mm: Fix MIPS32 36b physical addressing (alchemy, netlogic)")
    8f3e474f3cea ("x86/mm: Add task_size parameter to mmap_base()")
    97f2645f358b ("tree-wide: replace config_enabled() with IS_ENABLED()")
    9e08f57d684a ("x86: mm: support ARCH_MMAP_RND_BITS")
    a60ae81e5e59 ("MIPS: CM: Fix mips_cm_max_vp_width for UP kernels")
    b1b4fad5cc67 ("MIPS: seccomp: Support compat with both O32 and N32")
    b27873702b06 ("mips, thp: remove infrastructure for handling splitting PMDs")
    b2edcfc81401 ("MIPS: Loongson: Add Loongson-3A R2 basic support")
    d07e22597d1d ("mm: mmap: add new /proc tunable for mmap_base ASLR")
    e13b73dd9c80 ("x86/hugetlb: Adjust to the new native/compat mmap bases")


How should we proceed with this patch?

--
Thanks,
Sasha

