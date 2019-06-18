Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 002D4C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:57:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9271A20B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:57:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PzYEh9w1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9271A20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1928E0003; Tue, 18 Jun 2019 00:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A2578E0001; Tue, 18 Jun 2019 00:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFA498E0003; Tue, 18 Jun 2019 00:57:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5FF48E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 00:57:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so8489997pfj.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:57:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Lv+cXuvZHvNGp1JzMpt+J5WYS+JPWa0kgv1lbZiFhv8=;
        b=e3EJUivDZfnnCnxQz6cn4uZT0Rzq9f7B60LZ0oICtSCI+RPWwYxJkbLUGNYlkeNUoq
         enxaV8Srb/REms1aXXKYRXP9B72mSEk/paPneSTxsBmURAWNxDtOx3zVZpIXDmyBWAKt
         87WbilSm3R71BidLGEes3ytkgRnpIlfu3Y2ZzKXQE3viNw9AlDtsOmzylesgPJXYIoI0
         wItUuWtMRDSCAWirNlCAtcGp7jVGqe8DQKG2GdvjPbevP8dNiI40ed+fpjVs9FbW9lai
         nADwWGdrUx3qy6sPGSHh98eQ/0xaTKLkMv+5AWa7epgG0QutHvtdsNTOW4gcwY6NsllX
         l8Kw==
X-Gm-Message-State: APjAAAUIqFn2RUuCxDeCRi4l3UjiY3aHwSu1uv6rtc+QtmEToaIpi7jH
	4IBnvf6xWUEWfaJoHcxytfqKTpB6wEUdnpC9JMaAKjQMeiCAXCdmkRt+nDN4btj/34KHGpMFA8P
	AmASghJPr+q/g7B1kWs/d3otU8csUrqNXJ0WnmaQtdWyzdtjNAP9CbwqJeCuzmQj3Yw==
X-Received: by 2002:a63:5b58:: with SMTP id l24mr853772pgm.303.1560833873195;
        Mon, 17 Jun 2019 21:57:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPoRRP3o1AxZDGGAsf/wOCtHMkkmTwrkaWz1NDqDYsdAz4r7z2+slwGQgTIXiLIzCqDJAU
X-Received: by 2002:a63:5b58:: with SMTP id l24mr853741pgm.303.1560833872388;
        Mon, 17 Jun 2019 21:57:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560833872; cv=none;
        d=google.com; s=arc-20160816;
        b=O33Rtb657E2mvFgfU2f7vG0epUTFPDEqdDWYFOr+8hEyW/LNC+PB8w1mk60UlH3GZN
         7XIkuz4654YcL6IHpOvhmK2jzvpVB1cusRWb3NhS1kKLWFRvKBGj+3fW1jv6gtomePee
         wHjyZlfm+RuQcaHFqaxeYMDstSPs7z7LSyqqmliiIkQF3IvRfo5A1O+tjZ57dXIAgUMK
         5RdOkS/ulw6wRGHz/H/m3FJVq3arlh4eOVqs4U6Y99QaR5uzHnNUnklg5gb3clXgBNdZ
         +1q5MMWfGsCkoHrt4lFyGO+qSTjeGVB0H+DJFUDV1Vph9z6LnXMhtH8+AC+H0OFVBN9A
         KrTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Lv+cXuvZHvNGp1JzMpt+J5WYS+JPWa0kgv1lbZiFhv8=;
        b=VBrRaUbWGHl/YEVj1jNPHlC2UZ6JSM1Lt3fKLBFZQE7txPf+qXVTeZKlcZZwZbLANn
         Hna7QuvoVepNHE21treqWbZgyYzI6uB6nXqad33fDX4QF4TRTCHN/LIObIfKaQejZxsA
         bNIrqaSZdqIUn0YHcDjD3VXlOwqr6/unGVZ6wQXKP2AjYZJZAmDLfkoVtpTFtGv0waX/
         bMH87/41ooZSaDIaKzCxgShsv4BOeaVg8yuTO+J/o/lEa1YBER9udXaYWBz1Ah7MBycF
         yvFpXL+KX4M6TYcAPaO19dWJzWXRGiEm/WmGPuS//Q8l6T4ypTiQwz1G33yTy2RBuZ5u
         YoRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PzYEh9w1;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l185si12920370pfl.190.2019.06.17.21.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 21:57:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PzYEh9w1;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 655802085A;
	Tue, 18 Jun 2019 04:57:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560833871;
	bh=w+gB2F5dYye00PGW41w3Ta0fKYcvbRLeUI20zlmMIcs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=PzYEh9w15oAHl/5+DWIcKrLey234a0uiq0n8QAcsKIIvkD+9bOlHnZiXlY3FTrD8z
	 QbGYu0AkfxcGrKu700nhTv5AAxsUusMx2xVPd71iWWvU71sO7HwW6NZ3yMOVjWY/tl
	 ddlDhLRXEMz8eUrp9pUXynA3sqlPR14qWsnLehLo=
Date: Mon, 17 Jun 2019 21:57:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Borislav Petkov
 <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
 <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
Message-Id: <20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
In-Reply-To: <20190613045903.4922-4-namit@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
	<20190613045903.4922-4-namit@vmware.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jun 2019 21:59:03 -0700 Nadav Amit <namit@vmware.com> wrote:

> For efficient search of resources, as needed to determine the memory
> type for dax page-faults, introduce a cache of the most recently used
> top-level resource. Caching the top-level should be safe as ranges in
> that level do not overlap (unlike those of lower levels).
> 
> Keep the cache per-cpu to avoid possible contention. Whenever a resource
> is added, removed or changed, invalidate all the resources. The
> invalidation takes place when the resource_lock is taken for write,
> preventing possible races.
> 
> This patch provides relatively small performance improvements over the
> previous patch (~0.5% on sysbench), but can benefit systems with many
> resources.

> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -53,6 +53,12 @@ struct resource_constraint {
>  
>  static DEFINE_RWLOCK(resource_lock);
>  
> +/*
> + * Cache of the top-level resource that was most recently use by
> + * find_next_iomem_res().
> + */
> +static DEFINE_PER_CPU(struct resource *, resource_cache);

A per-cpu cache which is accessed under a kernel-wide read_lock looks a
bit odd - the latency getting at that rwlock will swamp the benefit of
isolating the CPUs from each other when accessing resource_cache.

On the other hand, if we have multiple CPUs running
find_next_iomem_res() concurrently then yes, I see the benefit.  Has
the benefit of using a per-cpu cache (rather than a kernel-wide one)
been quantified?


> @@ -262,9 +268,20 @@ static void __release_child_resources(struct resource *r)
>  	}
>  }
>  
> +static void invalidate_resource_cache(void)
> +{
> +	int cpu;
> +
> +	lockdep_assert_held_exclusive(&resource_lock);
> +
> +	for_each_possible_cpu(cpu)
> +		per_cpu(resource_cache, cpu) = NULL;
> +}

All the calls to invalidate_resource_cache() are rather a
maintainability issue - easy to miss one as the code evolves.

Can't we just make find_next_iomem_res() smarter?  For example, start
the lookup from the cached point and if that failed, do a full sweep?

> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();
> +			invalidate_resource_cache();
> +	invalidate_resource_cache();
> +	invalidate_resource_cache();

Ow.  I guess the maintainability situation can be improved by renaming
resource_lock to something else (to avoid mishaps) then adding wrapper
functions.  But still.  I can't say this is a super-exciting patch :(

