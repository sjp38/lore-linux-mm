Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2913C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7732A217D9
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:47:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7732A217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16EBE8E0004; Tue, 19 Feb 2019 07:47:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11EE28E0002; Tue, 19 Feb 2019 07:47:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0363E8E0004; Tue, 19 Feb 2019 07:47:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D57A8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:47:45 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d9so8462394edl.16
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:47:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P5/zlF0aYTIfU+/nMdjL6AaK7csXTZE9Cizn+7ahs6M=;
        b=J4E4iQnTvezjIFUBY1M67zkfiJ3AXhRIBKLeG6EjpvQTaYQP79cHJn0xdzkRGh8HC7
         8QAIOopO8Z6vxk7uvtbh/2EjzWmQUGGiQZ81DKt2f/tkxXReWIHTm2J1dr/vY5VTMaPy
         BglNdseyPSWzGeh2A4jaCC7mtNvimmp5osfKgn2xvbR2/2eTYZ9Az4Ee1cCyjp1ywGt0
         6oHCNKtXSEuJ7znKZItpE9PpzIgDSC3ZyBSXElUDQR/QIciZbOBrCT1S9slzQUp60qpG
         MhyxcoliGsU0gQzNLeL0HzFcfyIT51AhCO9zi+boDAQ1ZDti7geLbc7v03tOhgr1yBMl
         dYlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAuYPYWw8c+uduVvT4YfM2ctyVbGTxNvVyUgMbOjtK+K/sD1FE3lY
	RkYZg3fUdSWwHxp0cIlfRLgb9wiwG6SZxLgAynQxY0qwgInOEgvJuUTK0iUepXf8Jiqoc2hxZZg
	IMmIaAfnd3QI41XFsSY3+5+uCmtf0yEqRmBwPcPTCoLqCUXT2PLrOlqlb0EVTr5TQxQ==
X-Received: by 2002:a05:6402:171a:: with SMTP id y26mr17317444edu.72.1550580465216;
        Tue, 19 Feb 2019 04:47:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IadsGATr+pRrZOGpq8bvRUuRwydDpIkBi0uSVfgxlYf+6oDcJ3vfszIghhJvuGvTVBX4Fio
X-Received: by 2002:a05:6402:171a:: with SMTP id y26mr17317411edu.72.1550580464555;
        Tue, 19 Feb 2019 04:47:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550580464; cv=none;
        d=google.com; s=arc-20160816;
        b=WWHWrkJp/5M4i2iRupODZalxAqbTnLmf+fMUhHmDJh6wYA/q1k73YAdRfI5EsA5ABt
         5oQNXAN1TOoUryGnzuIjweh/6AJtVVZvh/l9sNLQ55jItjzHMmmohdTT/2roJJ/lXn6D
         UAHPOEr5g2thsn1KPc6Zit69k82d57IPtCxhm6sZ5Wm5TtW6C/on6VRlVsDYs12MeFD6
         gwvA11Q0i5icgLk23R7isu9lxLVxx5NCBm/WGkNnXSKXg1f/6UZOjXI5sguyDASqBZKC
         x1fyZZXL68CGssehRFggnd9BVlQqSDnKibv5jT9qaJf3f5UsR7ZsHrGSkM4aviXNgi62
         UZEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P5/zlF0aYTIfU+/nMdjL6AaK7csXTZE9Cizn+7ahs6M=;
        b=VaTC2RHqcffU2cu9SCDQ2gTttH4lqfMA2dUiJKwLLdaKdEy6nJEB6twurTKyR8XO0+
         CagtEG/1pMM5l7Tz1f7P8qyJmH3aqGq7I3KwpT9NPa4nLlLjwc9bF7fhRGL3s/zFrKkE
         Lgb9tG1RgvZTVGBClVCdhirR0N0jZzCDIU5ciea/B2nlIH7ENbQ+ELenyzLJLhWRtwTu
         01LgPnFVUp4n+wLfo8gDQhZsJnvUJN8M3/uj2s+6ap8v/0KTG/C8eBZ2l5Rzldf2G7E4
         cMrwwAJtEwgZwzw1t9ayt3NKNr5m9IZA57PQ3T+sY1ORk2lSB22OaABC6XHooKwAc2mM
         OaTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 18si5116974edw.88.2019.02.19.04.47.44
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 04:47:44 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 490F615AB;
	Tue, 19 Feb 2019 04:47:42 -0800 (PST)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7C23B3F720;
	Tue, 19 Feb 2019 04:47:40 -0800 (PST)
Date: Tue, 19 Feb 2019 12:47:38 +0000
From: Will Deacon <will.deacon@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org,
	npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux@armlinux.org.uk,
	heiko.carstens@de.ibm.com, riel@surriel.com
Subject: Re: [PATCH v6 06/18] asm-generic/tlb: Conditionally provide
 tlb_migrate_finish()
Message-ID: <20190219124738.GD8501@fuggles.cambridge.arm.com>
References: <20190219103148.192029670@infradead.org>
 <20190219103233.207580251@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219103233.207580251@infradead.org>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 11:31:54AM +0100, Peter Zijlstra wrote:
> Needed for ia64 -- alternatively we drop the entire hook.
> 
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Nick Piggin <npiggin@gmail.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  include/asm-generic/tlb.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- a/include/asm-generic/tlb.h
> +++ b/include/asm-generic/tlb.h
> @@ -539,6 +539,8 @@ static inline void tlb_end_vma(struct mm
>  
>  #endif /* CONFIG_MMU */
>  
> +#ifndef tlb_migrate_finish
>  #define tlb_migrate_finish(mm) do {} while (0)
> +#endif

Fine for now, but I agree that we should drop the hook altogether. AFAICT,
this only exists to help an ia64 optimisation which looks suspicious to
me since it uses:

    mm == current->active_mm && atomic_read(&mm->mm_users) == 1

to identify a "single-threaded fork()" and therefore perform only local TLB
invalidation. Even if this was the right thing to do, it's not clear to me
that tlb_migrate_finish() is called on the right CPU anyway.

So I'd be keen to remove this hook before it spreads, but in the meantime:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

