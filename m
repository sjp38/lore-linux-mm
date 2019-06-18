Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C4EBC46477
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:25:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E9BF2085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:25:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E9BF2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83FA18E0006; Tue, 18 Jun 2019 05:25:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C9928E0001; Tue, 18 Jun 2019 05:25:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68F9E8E0006; Tue, 18 Jun 2019 05:25:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 307148E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:25:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so20460559edb.1
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:25:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fy71Uf996E2ckvMT5DeFO9vx2wQVOL602KlAxeyozyI=;
        b=WAWMRVZDc5a00JrQUllfjYYC9mzSpqZjkdyNjuzrPnwUpA7CZtt9GDqcFRDkdprtGa
         /5TZIXYWw8dgQ+f7gnBKN63DnmV3xA3yYf8Q7kGBJ1oDyElPnx7zI5MOC0ozRNIeBGbT
         NqqTB1krxnV6+g0r0LsDVTpMf/hFzuP0GxqNWlMSq3Qp1xCBIql8pe6hRQ7ikjnMyt4U
         ODoVNwH8F8jpVxklOkR9KkKIloRajHifKjS5eQXB0FA1zzKcVwFEInNxQSlpg2a998Se
         4mblHG2ad9zZCOmggxR28LI2KrIV4HM3sI+9T02Ftqd8lKGMyk24YEnb6FSh1Ux0tQOp
         O3eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAX0lObta/mnAZqkoG/nMyJjCMuQahf70vcwRxp7/QQwp7SDDqlQ
	oIL9AGB9i9WOjRRbX239Ko9d36dMHaDyUOTDmGuQ8Hyj8VoZ4gTV1XfzxEorPSdyy73UiQpRiyb
	QqvNRZUfx95VMwUCCGQJ/X2yOHHg7t94CgIN64ALYNtVoFU9lyL8GeikYdvdRlir5Nw==
X-Received: by 2002:a50:8828:: with SMTP id b37mr82272363edb.266.1560849951616;
        Tue, 18 Jun 2019 02:25:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxD1zAOroYBBEBhR8uanimKnFlJkJ77QirG2ScbNFaAY0Jawsi+OB5G1UFvm1KdDijPFdb9
X-Received: by 2002:a50:8828:: with SMTP id b37mr82272318edb.266.1560849950995;
        Tue, 18 Jun 2019 02:25:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560849950; cv=none;
        d=google.com; s=arc-20160816;
        b=CM719RHsbHodAZNe08gXJxBSgHn/M3La5z4MERyuuxwz2hwooUO+xPw5DCn4j9MFWf
         1AWcZLnGG5iePbCR6i+2YNbd1+Gpcjf8E6EHv5xnT/XCEnwGJJNRIUPJGBJxaexngEdS
         XgVFjaJFTsiXNk4R3JTx4rZ43Awtc8i5b9J3/m6z/pLwUTYncNR1sr5oZ3zRcjPf4ZDI
         HrUA7qAdRRQLtwGnopYMFaKMps6KlhNHH0q1iZ9cjNM9usRixgwm6xaKj87nr6D6XGcn
         UVPw+9wywkcQTrqJ2Che6VzjyOKzh0G+g+w73By1T1dwNusboylh5P2IU0Q2FaaO0mqc
         kg4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fy71Uf996E2ckvMT5DeFO9vx2wQVOL602KlAxeyozyI=;
        b=NS1LKhpPdFzNL3m/SGaAXH9f8SJBDN357puCDYhAIW/L93GMZ/avIyqSOqywyA1pgB
         ekqZAoyNpdbo3Wy18U+P20XogSqcnm1z51EEUTlk/XabYF+qaR3Kg3Q2t1Ckynr7kC1k
         Czn3YpfJfiHzlFQyrbhC7MGxBiKX70bADy0fphsKMMrNA8/XYZMoZflZWaMelnOLQ+cR
         nkTLLa4oNnKR57jDo3713KcKE+Nl4EzAA5n4NhvrNu2k3LHakQcvwjBOPWG9t9I4frVF
         hp7Q6C8iht93jHEU83k8burXcZVONbpA73Sg6S3sa9NKQQa1ufC1OoSvX6r9Do2v3jLF
         xZ7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g44si10500460edg.58.2019.06.18.02.25.49
        for <linux-mm@kvack.org>;
        Tue, 18 Jun 2019 02:25:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0E4EC344;
	Tue, 18 Jun 2019 02:25:49 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E40263F246;
	Tue, 18 Jun 2019 02:25:47 -0700 (PDT)
Date: Tue, 18 Jun 2019 10:25:40 +0100
From: Will Deacon <will.deacon@arm.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH] arm64/mm: don't initialize pgd_cache twice
Message-ID: <20190618092540.GA30899@fuggles.cambridge.arm.com>
References: <1560843149-13845-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560843149-13845-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 10:32:29AM +0300, Mike Rapoport wrote:
> When PGD_SIZE != PAGE_SIZE, arm64 uses kmem_cache for allocation of PGD
> memory. That cache was initialized twice: first through
> pgtable_cache_init() alias and then as an override for weak
> pgd_cache_init().
> 
> Remove the alias from pgtable_cache_init() and keep the only pgd_cache
> initialization in pgd_cache_init().
> 
> Fixes: caa841360134 ("x86/mm: Initialize PGD cache during mm initialization")
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/arm64/include/asm/pgtable.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Thanks, Mike.

Will

