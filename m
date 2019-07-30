Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 011E7C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:57:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B372D20659
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:57:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B372D20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 614F38E0006; Tue, 30 Jul 2019 15:57:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3DA8E0001; Tue, 30 Jul 2019 15:57:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DA5B8E0006; Tue, 30 Jul 2019 15:57:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 195568E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:57:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h27so41472866pfq.17
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:57:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YKcd91XONjZ9R/TEZeX85NGuCg51HxrtHseW2D1VYwg=;
        b=Gkkg0ZcBHNsjf03BBUR6IhQILHnwmUbfjtJXy8IogH063abp9yKkSRGphrYUBSbSUS
         9dYtGhzPs8iH7av6Sn5muUFhPPrdd6RLNgQL+OEYvrt1Zftz+G9lINrei0zmsLeXavEq
         U7U7GH2qY8txsLo8nO9J8kGSxuCg/HJGM3UZqt8HLxFaLmdmVG20E0zdTYbf65p6LC18
         W0DuoBzmhJzet/6ejLWH41Xt4mPw6oY1UXO9WqqfsFOO/XEZiAuuKlW1TUa8Vv78rlNY
         cRwI94vwgivgmpWtEwHJ7DPybaEZYm6DkV25LT90DTgbvdvbvEpgjhOJ+t6Kgkb9Ql83
         VY0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAW4TYoRmA3SuoLYKy4JAJ6V3RwmH5sv+O5wpDcxTTGENtiEgob6
	pTbtYpH2Mr+ElEkyrMB/yHZmNF41nVErqLaIkJ2ZP8nAADRo7qWDueFrP+/YIiGW40SdOCkOmEw
	w4VNaRKrfivu9nuVl0iccLfyoYaLf/867sUAut5LnZEbq3iSUGoR4w04S9fC19CBVNg==
X-Received: by 2002:a17:90a:cb18:: with SMTP id z24mr66492499pjt.108.1564516668769;
        Tue, 30 Jul 2019 12:57:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyT8ygWGByGiPRHqLAGKqS03ctSRWot7TIzWhqMNxELeupfcr1/n9Al3hwmjUPjpMNC37As
X-Received: by 2002:a17:90a:cb18:: with SMTP id z24mr66492462pjt.108.1564516668124;
        Tue, 30 Jul 2019 12:57:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564516668; cv=none;
        d=google.com; s=arc-20160816;
        b=sVj7iJstBGbatT+B5TgVlQc1HA0jppdCzXbtGqxx+YROhHVewU9JQqrcIok0XYUB/C
         6BE8IXx0ag/MfawlXMuUatCTdSMzjYOLYZNzCjo5DVfSp7G/5StJlTjhhUDTAjBG/jP5
         KEiPlvwH0mw92Uu0poq2dIgRFP1RX/DMPU/13jmOX8b7V5m6I8S+W2KTyxrFffwmtSHX
         +Dlostt00SnVGmtnj5Y5tw1Wupgo8C5uw4LEec+jO4iBMVgYoMV/SeYIxF9ucOnCC5ED
         qGXADKzMTvTuIGr8NBixALAaL4+s24zlWRHaAI8ZPMB0d+iFlYQt3LJcxcyi+0l4aVZJ
         934g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=YKcd91XONjZ9R/TEZeX85NGuCg51HxrtHseW2D1VYwg=;
        b=p0XbZ9ixXbggOebEAwjM9dz7JaB5DCp8B2b9w3J4ddrrrz+zTZGA2O+9OHKTz7iiub
         8YzRMmlATFYW9+EonyRtaDWwShC35kcqFbAEsSsG8EoVqHkWd+fYVC3D/k5vsOT7eAO1
         UsMP3foWdJ5kfsrRh7MefycnY9IE8KmFov+/7fsI0YDIjAzxrKtg3jySOE/Ohl/nIQG/
         8GCuxfoZT6epwko6M7XPxj6aICE9TK2Iyqzj14wraTZodTLnaqNycvb8RB2AG14JzPi6
         qSm2Ko9KqGRaa6Hpv8BiZws54xdbcHkTHvqDbqTqXC2N3qzsc0LLJTvFa1/cF31ylL+7
         MZqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id br15si28528290pjb.43.2019.07.30.12.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 12:57:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9EACF3197;
	Tue, 30 Jul 2019 19:57:45 +0000 (UTC)
Date: Tue, 30 Jul 2019 12:57:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko
 <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Qian Cai
 <cai@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-Id: <20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
In-Reply-To: <20190727132334.9184-1-catalin.marinas@arm.com>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:

> Add mempool allocations for struct kmemleak_object and
> kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> under memory pressure. Additionally, mask out all the gfp flags passed
> to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> 
> A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> different minimum pool size (defaulting to NR_CPUS * 4).

Why would anyone ever want to alter this?  Is there some particular
misbehaviour which this will improve?  If so, what is it?

> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2011,6 +2011,12 @@
>  			Built with CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=y,
>  			the default is off.
>  
> +	kmemleak.mempool=
> +			[KNL] Boot-time tuning of the minimum kmemleak
> +			metadata pool size.
> +			Format: <int>
> +			Default: NR_CPUS * 4
> +

This is the only documentation we provide people and it doesn't really
explain anything at all.  IOW, can we do a better job of explaining all this
to the target audience?

Why does the min size need to be tunable anyway?

