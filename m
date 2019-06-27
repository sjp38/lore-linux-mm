Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EDEAC48BDA
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 04:48:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F43F20828
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 04:48:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F43F20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C72706B0006; Thu, 27 Jun 2019 00:48:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C491A8E0003; Thu, 27 Jun 2019 00:48:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B372B8E0002; Thu, 27 Jun 2019 00:48:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0016B0006
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 00:48:07 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x13so603741pgk.23
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 21:48:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=fFCugwwdiwgh8+6NJat+j6t1/UJ3sSe1kqP9UMErh78=;
        b=fO6Jo2qNPtNuPoZY79v0Hr2OP/DdIW90WjtS2wJdL6pOyViCXWp55cqnXf+n2TEsGg
         XXStA72A1FYYY4DDbJmvEp9H2MKQYixSR8/7BVKaQpOLvK7iBI/4CMwilZyNuVUNAn4+
         W1yoaaMErcVRUnjfC0+a+J7Jl9h/HmlNVORUMWJ4BcQogkiY7aZiTYu0FrdHM2ZDG5gZ
         7rnHt9PocVtcllGdUNKCmdPTp2yqOUOJM+6Fs3JcC3kwQ1PFEYax7XmMXQ3dFBDUBURf
         tEmC6Kd8ppSB2yC/TdUCZPc3G9YohZbLThJ4TST5GhCFkHA57Eb9hWPxRHk4iYl/cnc1
         cZ/g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAUlzfw/DNauSV/FYHSlycEt8c3FwICgbL4YM2LJ/fhYbHvpsea1
	wTR7GYYXaMWuzmhVsZKWlZmiLS8GM0vemzv0yeOCVkcmvkgQd1URFGlfDooyIVVjWITW3NMazS2
	0GbJMubxDjgwNEJYBsHAxEOuyC4tja2YjgA00fHJZTqR4lfqQsE0ycWtNhKbIB1g=
X-Received: by 2002:a63:2310:: with SMTP id j16mr1866576pgj.238.1561610887114;
        Wed, 26 Jun 2019 21:48:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVqs7+OKBFsoG5DtVJdX1rCoaeD2pUcbLgg1COmfto2w5yGOeWogEwT92RiOjDuS95k6Xa
X-Received: by 2002:a63:2310:: with SMTP id j16mr1866539pgj.238.1561610886440;
        Wed, 26 Jun 2019 21:48:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561610886; cv=none;
        d=google.com; s=arc-20160816;
        b=XbTZt41meNx53MmJeQ+L5Q4dVtuJfXKj3o8/wF38qSStjlDBqq8OhhR3y3dbyJ4rSZ
         BFC4FDy9kLVVP+1BSOBZZtcqOPcWAviOmsjdApqWPk4x5G4RGF8sOE2/CD1fsQU6OoNC
         ODRTxo6kytl00e40wd3WMW6soxueiQVd3S9SoCD/yuuEF1qFUBk4BhJX2+HAsJsRc7LG
         OSWEnX3GfAhK3RbwHUQy35xXtIylXKIHpq4TZ/Zc2qtGa18zvXQUAYOUDm/woyO5pHwH
         7VkmAsJXbr/VY5Ef/X284tFXY/t3BffoY4b9HHpuKGJeTCWhV4+Quv/Fwpxn4whRO1gB
         Xcwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=fFCugwwdiwgh8+6NJat+j6t1/UJ3sSe1kqP9UMErh78=;
        b=IGVHHCXQkLmho24tBecVkwvGQMAhNtccMZYT3J2iO4NmLjy2YGfDyNcfYBPLHlK8u5
         1Y7dLCY3t8XVG1by83rysZ7ugpLhFWI3gY1J+MjW0IwctC3a0/GPIndj+WlWiu02wpt2
         K+vxwpBUDCF7ImRjElru8Yiy/HoM+4mEiv6WcZL0jlNlPmdhRjSDjEcSLTat3FoIIldL
         63mbBcISB+odsWeC0oqn6tIiklwixK4TNWotsW9KHoJYn8gyPjLiBwU1LgzXqqMzV1D1
         mzFqYoe+8xtpQwNc3GMX67wAZ9SEKWmQM0tHutNLUCIPMFOH1uXsdNB/m42VHO2T6anM
         MU+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id k2si1241472pls.196.2019.06.26.21.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 21:48:06 -0700 (PDT)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45Z6pW1Pl7z9sCJ;
	Thu, 27 Jun 2019 14:48:02 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
Subject: Re: [PATCH] powerpc/64s/radix: Define arch_ioremap_p4d_supported()
In-Reply-To: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
References: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
Date: Thu, 27 Jun 2019 14:48:00 +1000
Message-ID: <87d0iztz0f.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual <anshuman.khandual@arm.com> writes:
> Recent core ioremap changes require HAVE_ARCH_HUGE_VMAP subscribing archs
> provide arch_ioremap_p4d_supported() failing which will result in a build
> failure like the following.
>
> ld: lib/ioremap.o: in function `.ioremap_huge_init':
> ioremap.c:(.init.text+0x3c): undefined reference to
> `.arch_ioremap_p4d_supported'
>
> This defines a stub implementation for arch_ioremap_p4d_supported() keeping
> it disabled for now to fix the build problem.

The easiest option is for this to be folded into your patch that creates
the requirement for arch_ioremap_p4d_supported().

Andrew might do that for you, or you could send a v2.

This looks fine from a powerpc POV:

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-next@vger.kernel.org
>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> This has been just build tested and fixes the problem reported earlier.
>
>  arch/powerpc/mm/book3s64/radix_pgtable.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/arch/powerpc/mm/book3s64/radix_pgtable.c b/arch/powerpc/mm/book3s64/radix_pgtable.c
> index 8904aa1..c81da88 100644
> --- a/arch/powerpc/mm/book3s64/radix_pgtable.c
> +++ b/arch/powerpc/mm/book3s64/radix_pgtable.c
> @@ -1124,6 +1124,11 @@ void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
>  	set_pte_at(mm, addr, ptep, pte);
>  }
>  
> +int __init arch_ioremap_p4d_supported(void)
> +{
> +	return 0;
> +}
> +
>  int __init arch_ioremap_pud_supported(void)
>  {
>  	/* HPT does not cope with large pages in the vmalloc area */
> -- 
> 2.7.4

