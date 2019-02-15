Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6DD0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 16:48:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D391206BB
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 16:48:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D391206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27EAC8E0003; Fri, 15 Feb 2019 11:48:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 208E68E0001; Fri, 15 Feb 2019 11:48:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D2DA8E0003; Fri, 15 Feb 2019 11:48:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A511D8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 11:48:56 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x15so4234479edd.2
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 08:48:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hocUS+4WIVmLQlgxns18lkRc3VuCIgC1yKblcJJS3gE=;
        b=pz2vDZO2AIG9UEaAtn9swK1XlXkDtczM8ezS2RRGRW1+/e96lm1nAGkuRgIRXkz+KO
         Hai8eiRI1VsFaXge8lJXFADG5cCZ0BjqpwKHvND62Ing0JUWZkGTQGK0QA3BJ7zBjOQp
         I5tOYkZgUmP9jLmE91rMznryHLFcG0ApVtsBq0xUtUEtQTrYy1rLPjMXNO0bc6qY6hA0
         Idy+mI+ZhIbQHDv0mlUtVRlPcx2jgqFBcNVSn6rwDLueSA9I2DQeDd1GSXfV0KKcPZlv
         LnvC7G/hs6io/py9YqHh0LfJgiuwor0GkD0prhmhV8liDtJkOmwHDE2jyybldBnzCbkK
         Btug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYDvba/f/PrFJAVXVWTDb0F9slcQykCU9/g9u+a8dIlQIlo7eyi
	LwyYPEEygVvudeGaW/0Tbdz8m9tvubRqMSnlETfBr5BHxSiHopJi4al5jwMcJH5MWntsnqVXLCB
	/97sLjF9Sn0892M+UORm4hTmzknub/huEaHChq5XLdXdQthb1VxT5XswsAylJCeyy2w==
X-Received: by 2002:a50:a901:: with SMTP id l1mr8418024edc.90.1550249336162;
        Fri, 15 Feb 2019 08:48:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCWAL/FfPeYe0srKCasK63FuEF7CKrdyaqSBAUrEN3d3tcWyDVjQknTHv49f2L65rJeOxr
X-Received: by 2002:a50:a901:: with SMTP id l1mr8417971edc.90.1550249335126;
        Fri, 15 Feb 2019 08:48:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550249335; cv=none;
        d=google.com; s=arc-20160816;
        b=wOE+7eAQbLagyiLCOkrx6/s5TssoJ0k/L9YftQO6C9FrobqRhFFBryvCHF3GVJ1vsL
         7FIzl6HUzKhFoAHRShoAIsRq8c7NOqtEyOn+bn8vlVEYVV6TwTQR+ZuRQwqAlnv+eiOk
         +w73J5nEh4jsZuEfrG211Jb3yDDFdj0HKoOqU+tTeZAD0UYk+fJm6yBElfPay5JSyjVM
         kg1vGLr5QgyMw9ryMb4YCd3rIRkmNCNYse8wL8ihTjds1W9MNWOjmSDDVOylQrVUJTEp
         zuIeHSoseWGaDbs20BS4/H2f1JKDyQX3WBRlQnJG9JXxG51Co8a+u6gX9WFYT511n27m
         5sxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=hocUS+4WIVmLQlgxns18lkRc3VuCIgC1yKblcJJS3gE=;
        b=xr+JFm7LAZEssZx0OULnYuwyRhFx7exQQdCjaZA9lFSOhZcPg0Q3TBFE1/Yd+BaDnE
         5CbLmjefA6Lb0toUs+/FkVuaryAepyfkoUXAqLknEBBg+yAAytaj7EmoSXx1vqR1qlNB
         G5zFFg1C1hr9iI/O5UU1x5oD3gossap6qsRnjdX+KIk9bfgY+BQG7v6pP/ss50aGFbNN
         7Solg1th/1wn3qdPHEpykOPTu6r1AxExn/c+0sKhJI07qwMp1AiZwGWQ39hPJdAGkgJv
         UG4MSVvx3n/GowtypnYVSHcIiRUMPczsH0BjniNIYtpk9dBMGjka+ZcxUzEZePFkr449
         hnIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hk14si2546887ejb.26.2019.02.15.08.48.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 08:48:55 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CF894B03F;
	Fri, 15 Feb 2019 16:48:53 +0000 (UTC)
Subject: Re: [PATCH v3] hugetlb: allow to free gigantic pages regardless of
 the configuration
To: Alexandre Ghiti <alex@ghiti.fr>, Catalin Marinas
 <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190214193100.3529-1-alex@ghiti.fr>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <363365a7-f1ac-5bde-ff7f-bdb137c20628@suse.cz>
Date: Fri, 15 Feb 2019 17:48:50 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190214193100.3529-1-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 8:31 PM, Alexandre Ghiti wrote:
> On systems without CMA or (MEMORY_ISOLATION && COMPACTION) activated but
> that support gigantic pages, boottime reserved gigantic pages can not be
> freed at all. This patch simply enables the possibility to hand back
> those pages to memory allocator.
> 
> This patch also renames:
> 
> - the triplet CMA or (MEMORY_ISOLATION && COMPACTION) into CONTIG_ALLOC,
> and gets rid of all use of it in architecture specific code (and then
> removes ARCH_HAS_GIGANTIC_PAGE config).
> - gigantic_page_supported to make it more accurate: this value being false
> does not mean that the system cannot use gigantic pages, it just means that
> runtime allocation of gigantic pages is not supported, one can still
> allocate boottime gigantic pages if the architecture supports it.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

...

> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -252,12 +252,17 @@ config MIGRATION
>  	  pages as migration can relocate pages to satisfy a huge page
>  	  allocation instead of reclaiming.
>  
> +

Stray newline? No need to resend, Andrew can fix up.
Ah, he wasn't in To:, adding.

>  config ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	bool
>  
>  config ARCH_ENABLE_THP_MIGRATION
>  	bool
>  
> +config CONTIG_ALLOC
> +	def_bool y
> +	depends on (MEMORY_ISOLATION && COMPACTION) || CMA
> +
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT
>  

