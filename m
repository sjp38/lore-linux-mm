Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F00E3C282E2
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 10:31:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B52621479
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 10:31:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B52621479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE5B36B0003; Sat, 20 Apr 2019 06:31:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D950D6B0006; Sat, 20 Apr 2019 06:31:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C35BF6B0007; Sat, 20 Apr 2019 06:31:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 869E06B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 06:31:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 18so4918495pgx.11
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 03:31:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=hiHgGeq7y6M6RXm8tzukqrUNVKb/GFeQ+zvZXxY4fjM=;
        b=Z6dJxo9TRhdQ5qIH7iWGBUQoLVkqEDdzJhHphAC7aYNe5/aP/p2g43ceY7PKkTAs7l
         VrlO3A/eC610YZzwOyVFyQy/qn7uK+tsf9u970+RMvOtexpoJH9zHPufWiuo8WZ5K9AR
         DDI70Rzp6woHv1vF1dq4xN985jD9aSf+okmZHygnu3L8I87CJEwzX8vXn0Ev84/Z3p17
         emYEY66pp9/0XIrTf63mPx7OZDCbmxcbpNXqYAhcy1Wh/Hbx6jFinbTrG2GIfTfzEGll
         74iUCz3oK+ZZLINNjiDNYYRwZCFXStxF3mmlweEy4i20AVSCSANKZVgRjvI58fYdyrDt
         ncLQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAU7tSns6Fw7VID/oNFMchH+irNz0ErLksKGVpqyZGgPRAiQaTI+
	nt/+A86syNkmwWByoFzVUmGrsDgLxDe01AmdUTmgQdP+k6vnn+uUAsOuoPeTPWzHrPtONsO2P01
	JKoZi3j/h4XvuaFua9hWZemUSXABKtgvS42USh616+vQ+q5URvhDwnjIFVK2sX/g=
X-Received: by 2002:a63:4c26:: with SMTP id z38mr8779192pga.425.1555756295048;
        Sat, 20 Apr 2019 03:31:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydHGb036uHE1Azo8ygv5TY6TXfbRH1cwa2DjgV7w8SoR5zA1pOZU/LwxwSc8VbT2UtKXOo
X-Received: by 2002:a63:4c26:: with SMTP id z38mr8779140pga.425.1555756294086;
        Sat, 20 Apr 2019 03:31:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555756294; cv=none;
        d=google.com; s=arc-20160816;
        b=x32VbS/f4qKWtyU/OKddR2qNn2+kGsQ3IHFYXkHi012ViCZvmz0t62cYwxRzPNvsZ0
         tNDsgK+cr5lI0HyeuTS5xBZrNtLaixLbaW8EDGFf1zM7ly650+XvA79GNPW4jZJK/zwN
         P0YEe8lz+gJukCnkEQFWdkODLBC4ULriidxXuZhTYXt9UOydzPHX3DrXYGNImjgQUK9p
         tCjlHhIZXj1BC9nolcliONwX/IcpgEpSYYPS3vu8LssCu32r5/75+3y+1lnr8y8HfIDS
         QHNL7y2VnfAWG3Ju+hclY2Kgy1hOSaP2jFolUwOkyA97AQGq+Q8Ncqs2lUcWsTWKdk9X
         B/CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=hiHgGeq7y6M6RXm8tzukqrUNVKb/GFeQ+zvZXxY4fjM=;
        b=uS6LqQG0QGX/72SqW840WgbKU6m5RLjCMZWdmxUnHubGc9TJHtlMB+YAIMW885RtWV
         xq6ALBSJ61ZWgklWWsswo7jfuJW7WGg4eMBCYHwyq3vV0DCoYevhiGYpcW+OHOh7mPKw
         1gfRXIsU/2Xl0DBO+udiNKDcZ9wW5KDKORjEZiBs+J2wt+DHLvXmnKDe6yeQ7p7OPodf
         b7HWSb21KPjyK6kZCnJ5EjFaLIIkyq9lSStMwwve7H+3j5WYUyIZiToHzxR4pR5rwqMw
         8kUi19H2z6qwpGwjsDEqtsfjTRigZnS9fqxB1AjZYwRKTgWfmwPjnhyVmWSDIJN5o701
         Qg/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id q5si7188088pga.498.2019.04.20.03.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 20 Apr 2019 03:31:33 -0700 (PDT)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44mTf91SR8z9s70;
	Sat, 20 Apr 2019 20:31:28 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, rguenther@suse.de, mhocko@suse.com, vbabka@suse.cz, luto@amacapital.net, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, stable@vger.kernel.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH] x86/mpx: fix recursive munmap() corruption
In-Reply-To: <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de>
References: <20190401141549.3F4721FE@viggo.jf.intel.com> <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de>
Date: Sat, 20 Apr 2019 20:31:27 +1000
Message-ID: <87d0lht1c0.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thomas Gleixner <tglx@linutronix.de> writes:
> On Mon, 1 Apr 2019, Dave Hansen wrote:
>> diff -puN mm/mmap.c~mpx-rss-pass-no-vma mm/mmap.c
>> --- a/mm/mmap.c~mpx-rss-pass-no-vma	2019-04-01 06:56:53.409411123 -0700
>> +++ b/mm/mmap.c	2019-04-01 06:56:53.423411123 -0700
>> @@ -2731,9 +2731,17 @@ int __do_munmap(struct mm_struct *mm, un
>>  		return -EINVAL;
>>  
>>  	len = PAGE_ALIGN(len);
>> +	end = start + len;
>>  	if (len == 0)
>>  		return -EINVAL;
>>  
>> +	/*
>> +	 * arch_unmap() might do unmaps itself.  It must be called
>> +	 * and finish any rbtree manipulation before this code
>> +	 * runs and also starts to manipulate the rbtree.
>> +	 */
>> +	arch_unmap(mm, start, end);
>
> ...
>   
>> -static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
>> -			      unsigned long start, unsigned long end)
>> +static inline void arch_unmap(struct mm_struct *mm, unsigned long start,
>> +			      unsigned long end)
>
> While you fixed up the asm-generic thing, this breaks arch/um and
> arch/unicorn32. For those the fixup is trivial by removing the vma
> argument.
>
> But itt also breaks powerpc and there I'm not sure whether moving
> arch_unmap() to the beginning of __do_munmap() is safe. Micheal???

I don't know for sure but I think it should be fine. That code is just
there to handle CRIU unmapping/remapping the VDSO. So that either needs
to happen while the process is stopped or it needs to handle races
anyway, so I don't see how the placement within the unmap path should
matter.

> Aside of that the powerpc variant looks suspicious:
>
> static inline void arch_unmap(struct mm_struct *mm,
>                               unsigned long start, unsigned long end)
> {
>  	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
>                 mm->context.vdso_base = 0;
> }
>
> Shouldn't that be: 
>
>  	if (start >= mm->context.vdso_base && mm->context.vdso_base < end)
>
> Hmm?

Yeah looks pretty suspicious. I'll follow-up with Laurent who wrote it.
Thanks for spotting it!

cheers

