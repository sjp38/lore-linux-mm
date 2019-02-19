Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34920C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:47:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF7BD2146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:47:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF7BD2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6780C8E0003; Tue, 19 Feb 2019 07:47:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6287C8E0002; Tue, 19 Feb 2019 07:47:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 518858E0003; Tue, 19 Feb 2019 07:47:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB4418E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:47:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i20so624776edv.21
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:47:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pl2Jew+HCjZONhrpijigbZKFKNok/pGd4kFDCcyID4I=;
        b=CUlk37CIYSjv97m9AMW1y7vEfqvTICqLTyaCyLsr7bxwU7ZWmY/mCWA7EIA6uStIWH
         zPrgf0fZJMPfX9j7Kr0F9gb+JYCd31wTWWThT8iWpof7zaO4G8pX/BDkfvuWWclEoNeq
         5aZkMsUGmYhncQzvueeD7QxMky79+zUtUE6FQAdXzru4r49A/MmWCZ8AJeEgeeBXNYf/
         CV39A+hk7GnRb1nav0K9xAoflmYOInd15ichb0DSSZF90jnLwcU2zwIuSb9AFPIFEFnO
         cQX4R89RYD7/pBNkJ/tYJv43yeOStfXp/hxHarm7UvLAIG3UkajhMu8XC2KgZzfLcGOO
         Y2UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAuZxs+/fQDCZKRrdEP6vTgV1Ode+7ZrRaB36UKQ/odeFj++lRvkh
	wH+hPY6aFLCUzim+A+MYI5JZEzdBDeSuq5fdkmZ59w7XQWTktA9CaZkQEqiHVSUH4Qf6nIxyywf
	F6P6Q6w6RzxdnjT2Y7HPc5mgWxQI7tTmON6JGfIQsM1JxLqwD+iHdeFKRDswQ2wS32Q==
X-Received: by 2002:a50:ad31:: with SMTP id y46mr22665882edc.97.1550580442443;
        Tue, 19 Feb 2019 04:47:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbqOMbuticANtuv6TEP2zPJhuS9RLu+UCr4aXr/MFvVl47Jv0qOqopoB4VYum3oM3ec86Fz
X-Received: by 2002:a50:ad31:: with SMTP id y46mr22665826edc.97.1550580441530;
        Tue, 19 Feb 2019 04:47:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550580441; cv=none;
        d=google.com; s=arc-20160816;
        b=hIL4EMCKT9ogXG9I0PxniWeidM8UyiLLwHDRx6Ta5SQlY6uTX8AvxkmzFK4lv4M3/G
         13XX2nKgw2QCb07uBmSnh7zO/66SUzMth4edNsnLVEDO06BHl+ZP6yxuQB4J+F6wvoaR
         wagIZZr4YhKX4s2E1yFkb1ypZEK9ft0+0AWOo7TnCafATCF4LKU+seiWFYdct1HqK8E7
         +y0/G6C2zjyqrawboo8jbS0KQHUxA0beJPKMvCd2pnlk45Iw2kxttN9rWuTiPS26aB8R
         Bftd/hZCqkBqUfSB31djAmQcHrsW76s8Pv0rVfnhabtCRY2mIwz8YE6tA8qmpUk+uGiK
         obsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pl2Jew+HCjZONhrpijigbZKFKNok/pGd4kFDCcyID4I=;
        b=0RnS3mTFwuZCf1oD0Tl+sFPQnaOm5LpIVZ+xv0heSYyWstbXy6wC0jz5yqPDj06JQI
         3tI50ntD+JtY0RawaApmmSKlT4PLz6BeRTchkPkuTMBLqRDwCC8veKzOEZVm0UD+8P/I
         PMVqJMktE8HPy+Ic4ocFFIehFzcxe7y/d8Dy977YbYF9GSKFQMcFecbsMoXzIi83Lky3
         rD0OiJ5968Vgb0m5JtBUg4wh/VwiR2ELn3Lf9RgYa+jjHbAkKJmi96lRdCGmTeXfYPUN
         a1sGwdhEK8UPBzK+4BT/vc3BBCXQy4ZbJDmBMrE+TTn/TPt3M3yFilIMOQuzCPPxMnuV
         vf3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j16si1997176ejv.102.2019.02.19.04.47.21
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 04:47:21 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 566D9EBD;
	Tue, 19 Feb 2019 04:47:20 -0800 (PST)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 887213F720;
	Tue, 19 Feb 2019 04:47:18 -0800 (PST)
Date: Tue, 19 Feb 2019 12:47:16 +0000
From: Will Deacon <will.deacon@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org,
	npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux@armlinux.org.uk,
	heiko.carstens@de.ibm.com, riel@surriel.com
Subject: Re: [PATCH v6 05/18] asm-generic/tlb: Provide generic tlb_flush()
 based on flush_tlb_mm()
Message-ID: <20190219124716.GB8501@fuggles.cambridge.arm.com>
References: <20190219103148.192029670@infradead.org>
 <20190219103233.148854086@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219103233.148854086@infradead.org>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 11:31:53AM +0100, Peter Zijlstra wrote:
> When an architecture does not have (an efficient) flush_tlb_range(),
> but instead always uses full TLB invalidates, the current generic
> tlb_flush() is sub-optimal, for it will generate extra flushes in
> order to keep the range small.
> 
> But if we cannot do range flushes, that is a moot concern. Optionally
> provide this simplified default.
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  include/asm-generic/tlb.h |   41 ++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 40 insertions(+), 1 deletion(-)
> 
> --- a/include/asm-generic/tlb.h
> +++ b/include/asm-generic/tlb.h
> @@ -114,7 +114,8 @@
>   *    returns the smallest TLB entry size unmapped in this range.
>   *
>   * If an architecture does not provide tlb_flush() a default implementation
> - * based on flush_tlb_range() will be used.
> + * based on flush_tlb_range() will be used, unless MMU_GATHER_NO_RANGE is
> + * specified, in which case we'll default to flush_tlb_mm().
>   *
>   * Additionally there are a few opt-in features:
>   *
> @@ -140,6 +141,9 @@
>   *  the page-table pages. Required if you use HAVE_RCU_TABLE_FREE and your
>   *  architecture uses the Linux page-tables natively.
>   *
> + *  MMU_GATHER_NO_RANGE
> + *
> + *  Use this if your architecture lacks an efficient flush_tlb_range().
>   */
>  #define HAVE_GENERIC_MMU_GATHER
>  
> @@ -302,12 +306,45 @@ static inline void __tlb_reset_range(str
>  	 */
>  }
>  
> +#ifdef CONFIG_MMU_GATHER_NO_RANGE
> +
> +#if defined(tlb_flush) || defined(tlb_start_vma) || defined(tlb_end_vma)
> +#error MMU_GATHER_NO_RANGE relies on default tlb_flush(), tlb_start_vma() and tlb_end_vma()
> +#endif
> +
> +/*
> + * When an architecture does not have efficient means of range flushing TLBs
> + * there is no point in doing intermediate flushes on tlb_end_vma() to keep the
> + * range small. We equally don't have to worry about page granularity or other
> + * things.
> + *
> + * All we need to do is issue a full flush for any !0 range.
> + */
> +static inline void tlb_flush(struct mmu_gather *tlb)
> +{
> +	if (tlb->end)
> +		flush_tlb_mm(tlb->mm);
> +}

I guess another way we could handle these architectures is by
unconditionally resetting tlb->fullmm to 1, but this works too.

Acked-by: Will Deacon <will.deacon@arm.com>

Will

