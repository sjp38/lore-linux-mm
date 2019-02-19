Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C964C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:47:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDCC82146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:47:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDCC82146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B7FA8E0005; Tue, 19 Feb 2019 07:47:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 564598E0002; Tue, 19 Feb 2019 07:47:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47AA08E0005; Tue, 19 Feb 2019 07:47:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06BD48E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:47:57 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so1944093edh.10
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:47:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0IqujbWg9TJmxxe/ZqXKNWzmwe9oPvAf8Kpdb9YgI5M=;
        b=i+EM+or8rLDbXgBwZqZG0rH1aNSMnuPpTFhevlbTyxB/Z3Xa9ERwGCUtvo/+W2xcei
         lKphpSaqcxN/rXkURYLK5mY7RIpHFbPeTiGfpV5hPZ0Mj9VyFgdrl0VterQWoc/R07MG
         iLRX0fuVJ4r+SlawqssVQICtq7gxcA0PS98U/3UQ0nfJn7vH7oKok+W7LG8hpX/NeJ1H
         L3wL1FyYkD3R0JFHSwego5OdkAfCmubz04WZOTXaBZXNNAwO4yr9FsYpe9hT4d1RXGM0
         w0dV/79S9y4C0bJVUMSEfJUOPjFCbfZIefpzCs+jySNnq9QleHngAx9iBX3CAwO5DOhc
         CXdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAuYY3zcZyUHRfh4LzibT1p2xf3TMrZgQ6yVRalJ35fBRkqgHmvz0
	ws0dWYa102+KRwzkboR7UpLUpGv5YtkEtwHSl9wfIfgtN/VJgPwn+YxzLVzHINCAIvCDxnuRDK7
	g2JTe3YrcZaP59zQQmIdkc2MahClWCzVfYkIMHWsr9a7k5eCxYeRw4T/x5VUgPLDWQg==
X-Received: by 2002:aa7:c70c:: with SMTP id i12mr11642498edq.36.1550580476592;
        Tue, 19 Feb 2019 04:47:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaiVwun4xW2NxUApFgz6fMOxggOTmccOY0lRQyq1jGBGsBOuruNVYAgfTC9Nf3RQCIDpo4V
X-Received: by 2002:aa7:c70c:: with SMTP id i12mr11642431edq.36.1550580475592;
        Tue, 19 Feb 2019 04:47:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550580475; cv=none;
        d=google.com; s=arc-20160816;
        b=wOlI+ViPQ3n61UFv7lgJ9pIYbi5hlzxhQ90NlW/iL2xo+NJuIrtp4LYRWlye6o2n4N
         GEYLm1crRJd/gRcF9VEC9dBvhv6n55f3MXUwvVJ1y367/wzDCTkj2ir9tUcQ4n85H8g+
         Hp/fTsFyIXWlsabIclzTIqzrCuePKyNV7aY9d8T6PUrv3qzrrawVHGL1JBFTdBp2jYnx
         zyWQmqUlxxyZADIbMdc/yKUGH1q81HiHvHTjp0kYftLVF1LKLgqdI6ALEEhdJPivRAZ4
         dDG1O0ydHb79GPeFs7rSvMAXaiZywKo4iVWIhsewoN42OdGSzXTKFF0Rxb+XIsUxg1pN
         gaYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0IqujbWg9TJmxxe/ZqXKNWzmwe9oPvAf8Kpdb9YgI5M=;
        b=RzHQjA3C97DvXCll6Hc6H/gkLsTAb/tY0Sae4DfO4N2spREHUV2mFfpW2qKcy+fyay
         Uscf4Pez+6hU6YiA44nEETzouBdJY/SvZJSQ4uPXdQoNhTDkZC/xkQubHGfgfRXHNlc9
         zvWLjUcUf76WXtzrlHlcxoEbnM2jMBXCycTELYqCQsC/qIrU+ChAD6GbUNTsiXWlXyqT
         S5/KnxAsninI761k32jVtIfN1SE7f9+IHU9fvD+FU9gtvTz3q7PP+PloiFV/acnhF61j
         ISp3u1+Xo4qcnJgB904ojm+ukqRLbXXFoynhTZttoFUNa9yF/p7Dm3H7uFKx/VPcCyOO
         YpUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f26si1982053ejb.21.2019.02.19.04.47.55
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 04:47:55 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2419615AB;
	Tue, 19 Feb 2019 04:47:53 -0800 (PST)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 10B3C3F720;
	Tue, 19 Feb 2019 04:47:50 -0800 (PST)
Date: Tue, 19 Feb 2019 12:47:48 +0000
From: Will Deacon <will.deacon@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org,
	npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux@armlinux.org.uk,
	heiko.carstens@de.ibm.com, riel@surriel.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v6 14/18] s390/tlb: convert to generic mmu_gather
Message-ID: <20190219124748.GE8501@fuggles.cambridge.arm.com>
References: <20190219103148.192029670@infradead.org>
 <20190219103233.693323478@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219103233.693323478@infradead.org>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 11:32:02AM +0100, Peter Zijlstra wrote:
> 
> Cc: heiko.carstens@de.ibm.com
> Cc: npiggin@gmail.com
> Cc: akpm@linux-foundation.org
> Cc: aneesh.kumar@linux.vnet.ibm.com
> Cc: will.deacon@arm.com
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: linux@armlinux.org.uk
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Link: http://lkml.kernel.org/r/20180918125151.31744-3-schwidefsky@de.ibm.com
> ---
>  arch/s390/Kconfig           |    2 
>  arch/s390/include/asm/tlb.h |  128 +++++++++++++-------------------------------
>  arch/s390/mm/pgalloc.c      |   63 ---------------------
>  3 files changed, 42 insertions(+), 151 deletions(-)

-ENOCOMMITMESSAGE ?

Will

