Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E02C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:37:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4912D2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:37:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4912D2229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5AA58E0002; Thu, 14 Feb 2019 03:37:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE4368E0001; Thu, 14 Feb 2019 03:37:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C23098E0002; Thu, 14 Feb 2019 03:37:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3408E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:37:15 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id u7so2172367edj.10
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 00:37:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=phZviSWP5x1eg4g7+BvLw5Pvijwak9f4hIHwrlIVEmY=;
        b=oO51Bybxz+FNUQ5XPSnsEhRnnFEBqJeMOou4uxhsl78aDwHtzsLX8+2p9vNAddz3Bw
         DmDakAwbkl2KOeF7ruOQJWhiF2/MzoWCJeuE5U4JQSX/VTwOdxhehmnSl280zs1X3H5u
         v6pJ+iWdyX6wzSVhoO/cplq2fI+VKPMwb20cYiA65x3s0+B0YnRh+9iDjkKS2lE3KvQy
         dmZF52v+fzzrYBdIwRZxWPZ86dh8Fyh14mYUTQ1qdNqAThOwfGInyjFvAtiE+P2oKB3m
         iwqIM1a5zBWE9oUCJkkKk+TfK7wud3sHxgpkrkj28jKrXv/SSPNDh3wkgrb7hdHnWQNX
         /dig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuaU8fbPhiyRBkGzRnFYOzmmUyJKrZtOWVVCN8qJ149RdIaXitOC
	Mr3lZDLLhOD2W18qfia9g7aX4SpsAN3PyO0n/gAgsKVST5X4gnQ+pwMWrt3QkTWpfG43c+eY0nv
	YlW6kP6koGEvoTSrHZ9uIiLzFaxEdKcv5BlpD8v59Ckl8WUzdmQW8q124Nb3ITj/Ytg==
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr2184211edt.34.1550133434978;
        Thu, 14 Feb 2019 00:37:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IacjpoYaGgpL8D+J/NkNQSdQ8wLtO7AAfTr5nqTuG62sMJkqAculCOMUJjnACLM1L7kTFHH
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr2184172edt.34.1550133434003;
        Thu, 14 Feb 2019 00:37:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550133433; cv=none;
        d=google.com; s=arc-20160816;
        b=UvYqoI7e7kh2QDzEvbLAEHguqMmb8MLwD+um+n+AkSsBvXnwlA562+t9aI1+iaAnWl
         /ilxKoaZ+prPzkW2wcH/QIVa8HvDEfxGZdTVH5p55ISgdCXjmsJeTGrKxJRMKGiKDAUm
         cDoxdmMJS9IJ311tq1RbvsUW8JD9BxoSouYLxNFp2fMl8FWviJYWm8S+3bQBCKC0VWXh
         zknVlfIuRxlejCl0m5GJ80mUL224UFzItJeniV1oayKcGam34x+4Y43QJ2WGPtCn2D4E
         XrYbJm0LoZENeOh8EWWA8MP+i1lX00nMnCIy3qFjJ0axlMnugdww/KBmOyG6i8bVbXmj
         /lHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=phZviSWP5x1eg4g7+BvLw5Pvijwak9f4hIHwrlIVEmY=;
        b=sqOmj3ZhcPpRwNN66Pv16z0mgfVLSu7Dc7ce0GHCQwxqX1vAhfUTrPjLvwcdGLPtEa
         tlw2IN7NQHk//5F6ZyflJWzj8rWh0qr3xNfefQ0ucRGS3p/SIXvsdHIKuSpuG/TpcNg+
         7SL7ztymqqLfgUcK9fhbDR2u9TqSvArWg49a4UaInq98tZ3WobglAG1aCQI7nScik8W9
         FPY7rr23TODOV3+z6RISX218H3bKWNY5ji5qrCk+NXuC6wj4A33ftyQhg0mrO41AoN6N
         7ZvRrvxHUiG3VJFTZcq9dO/eVHxiu0BX4r0eStuSe5CVJFVouZq8GSatshyVqVJC+ESt
         UW4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r13si822620edb.140.2019.02.14.00.37.13
        for <linux-mm@kvack.org>;
        Thu, 14 Feb 2019 00:37:13 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 63568EBD;
	Thu, 14 Feb 2019 00:37:12 -0800 (PST)
Received: from [10.162.42.113] (p8cg001049571a15.blr.arm.com [10.162.42.113])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 478DF3F575;
	Thu, 14 Feb 2019 00:37:10 -0800 (PST)
Subject: Re: [LSF/MM TOPIC]: memory management bits in arch/*
To: Mike Rapoport <rppt@linux.ibm.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org
References: <20190128070705.GB2470@rapoport-lnx>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <2d0a7cd1-fdbf-b679-6692-440121e45a86@arm.com>
Date: Thu, 14 Feb 2019 14:07:10 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190128070705.GB2470@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 01/28/2019 12:37 PM, Mike Rapoport wrote:
> Hi,
> 
> There is a lot of similar and duplicated code in architecture specific
> bits of memory management.
> 
> For instance, as it was recently discussed at [1], most architectures
> have
> 
> 	#define GFP_KERNEL | __GFP_ZERO
> 
> for allocating page table pages and many of them use similar, if not
> identical, implementation of pte_alloc_one*().

As concluded earlier on that thread [1] apart from unifying allocation flags
as GFP_PGTABLE there is also a need for generic implementation for standard
page table page allocation/free functions like pte_alloc_one_[kernel]()/
pte_free_[kernel]() which can ensure that all page allocation/free goes
through pgtable_page_ctor/dtor constructs and user page table allocation
is accounted for it's memcg with __GFP_ACCOUNT.

IMHO zone stats for NR_PAGETABLE and memcg accounting for user page tables
should not be arch specific and the semantics should be same for all.

>
> But that's only the tip of the iceberg.
> 
> I've seen several early_alloc() or similarly called routines that do
> 
> 	if (slab_is_available())
> 		return kazalloc()
> 	else
> 		return memblock_alloc()
> 
> Some other trivial examples are free_initmem(), free_initrd_mem() and,
> to some extent, mem_init(), but more generally there are a lot of
> similarities in arch/*/mm/.

Agreed.

> 
> More complex cases are per-cpu initialization, passing of memory topology
> to the generic MM, reservation of crash kernel, mmap of vdso etc. They
> are not really duplicated, but still are very similar in at least
> several architectures.
> 
> While factoring out the common code is an obvious step to take, I
> believe there is also room for refining arch <-> mm interface to avoid
> adding extra HAVE_ARCH_NO_BOOTMEM^w^wWHAT_NOT and then searching for
> ways to get rid of them.
> 
> This is particularly true for mm initialization. It evolved the way
> it's evolved, but now we can step back to black/white board and
> consider design that hopefully will avoid problems like [2].

Factoring out common code one specific function at a time would be the
right approach. As suggested during GFP_PGTABLE thread, first define
a generic function and switch one arch at a time to use the generic
one. This will give enough time for each platform to evaluate before
subscribing to the new generic function. I would like to participate
in this discussion.

