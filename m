Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39503C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:10:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 817512077B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:10:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 817512077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD4A28E0095; Thu, 21 Feb 2019 12:10:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C83EF8E0094; Thu, 21 Feb 2019 12:10:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9B578E0095; Thu, 21 Feb 2019 12:10:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62A0B8E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 12:10:26 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id j5so8143493edt.17
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:10:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Z4Jd82puYiI0Wpk2FE+DsqB8z4biSf3t5IYfnkCnYBc=;
        b=YmNSnjNEN9QzU2reeZXqYYKqdlkBohwkqVgl21Kbx0uxvWXOUBmxZMbybMpyHVx99i
         ByyNYCi+b0yDJxOt8KEBAH/Lky5pnGSwyOM4hXVdmnNbHr1oWkl7dfZ//zjm5alWN8hJ
         +9r4Cnn9zNwWsDQXi8xLmR4DENrifvB7ASQpGIU86GAYWf9f61UUs7uWf90l6wotfLmj
         f6RlNm2D6dP4NF1aCKPZHL1xlRFq39FddECFQkDjVQYm2VUsqa7JQt5etgX6mZ8Z2d93
         qmJAPSiJMtJYJchRytLPoxdR5PhbDem2AbC+5Nqwyz03kg8wvkYlFlJLg9x5bc6fFDTc
         z0Rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAuZeOKg2gcaefLerkjw0/KF15IXZboGYg1sT14RghoWoUgJeziSM
	Yp6ydhI8sGmz8jDj7MG3+hscV9EzStd4EjKGzPMk5h8quzIBFDhNq0hT06H91XFG4XnzWuEhZFZ
	GwR7YwAdRJgSW/vGU0DxECMWvHmIs5+sHnjcROFdncDoxYPrIiYrdwZcVyar7yu8vkA==
X-Received: by 2002:a17:906:f1d8:: with SMTP id gx24mr3329384ejb.227.1550769025898;
        Thu, 21 Feb 2019 09:10:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYi3iZkfcplO1/uOXg99Q0mvheZduRDq0CT9Q+2nV1AaYRYyW+A8oseoeldfnEbtofY0ltD
X-Received: by 2002:a17:906:f1d8:: with SMTP id gx24mr3329301ejb.227.1550769024538;
        Thu, 21 Feb 2019 09:10:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550769024; cv=none;
        d=google.com; s=arc-20160816;
        b=KLpbjbB245FH2g44ya/44OiMpGBY7A9WTFdaOIz591zS+/19j2y9VKl0Vl9vUttmgz
         3FuOgYt5EvKngGvGTQYmD4T3p3NLEyKWp+e9qcBJ386x38xfmp2jUHrGULWB0ZgRJkv3
         geI2idd2ip5efghQ/8OxrQ3UYzcJJxX7C2UvZ33DXkDmtPMev1wGFhKHT9338ICOdMW7
         g7eQz3Av47Deoo03h/2NidBCM2+9XXgjxdcKJ+qTuF/9Dj1Xkrg4+dKJ3IBD2W5sKoC+
         4lIysQ1sxIwMk5HBMFDR5/ima9LvwZnrjYgq4F+j0XG2ej61AuDNAUKjkt9fJg9N8091
         wqfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Z4Jd82puYiI0Wpk2FE+DsqB8z4biSf3t5IYfnkCnYBc=;
        b=Sha/M/NdQFrM6sKGGTrPQydMLjyoj7tT7ThmDyJgyTV+bUf+JoE2z0IrgddZ94qMxC
         q07qrJ52hR/fAME5C0/14tdy4FXXlkaMDmsrWtPHOnQJ86tlmgONs4m+zKXGPIzeSPeL
         OXzKCumXK13t9HpE6UMsbpLs5CHrH0FJ6LlelddduhlEHk6WGUxs9PD+zdh+w159UEna
         uDC561bo1zhUJ7yhBuYC7ez9sWo1d167lvLxyrgJTf/y+BepWB9/0eUKosBdnSE5zUmh
         iu3ubsDJ1Z/9vKwtAhsCNT4rpzTknpqoQZtq6gybQvar69JP3r2ck4oWJl6VZxybwFFn
         BvOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id t57si1244940eda.164.2019.02.21.09.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 09:10:24 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 178961C1D4B
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 17:10:24 +0000 (GMT)
Received: (qmail 18951 invoked from network); 21 Feb 2019 17:10:24 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 21 Feb 2019 17:10:23 -0000
Date: Thu, 21 Feb 2019 17:10:22 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Lars Persson <lars.persson@axis.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org, Lars Persson <larper@axis.com>
Subject: Re: [PATCH] mm: migrate: add missing flush_dcache_page for
 non-mapped page migrate
Message-ID: <20190221171022.GX9565@techsingularity.net>
References: <20190219123212.29838-1-larper@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190219123212.29838-1-larper@axis.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 01:32:12PM +0100, Lars Persson wrote:
> Our MIPS 1004Kc SoCs were seeing random userspace crashes with SIGILL
> and SIGSEGV that could not be traced back to a userspace code
> bug. They had all the magic signs of an I/D cache coherency issue.
> 
> Now recently we noticed that the /proc/sys/vm/compact_memory interface
> was quite efficient at provoking this class of userspace crashes.
> 
> Studying the code in mm/migrate.c there is a distinction made between
> migrating a page that is mapped at the instant of migration and one
> that is not mapped. Our problem turned out to be the non-mapped pages.
> 
> For the non-mapped page the code performs a copy of the page content
> and all relevant meta-data of the page without doing the required
> D-cache maintenance. This leaves dirty data in the D-cache of the CPU
> and on the 1004K cores this data is not visible to the I-cache. A
> subsequent page-fault that triggers a mapping of the page will happily
> serve the process with potentially stale code.
> 
> What about ARM then, this bug should have seen greater exposure? Well
> ARM became immune to this flaw back in 2010, see commit c01778001a4f
> ("ARM: 6379/1: Assume new page cache pages have dirty D-cache").
> 
> My proposed fix moves the D-cache maintenance inside move_to_new_page
> to make it common for both cases.
> 
> Signed-off-by: Lars Persson <larper@axis.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

