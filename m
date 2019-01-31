Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 145B8C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 22:14:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0D7D2087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 22:14:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0D7D2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D5BA8E0004; Thu, 31 Jan 2019 17:14:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65B6A8E0001; Thu, 31 Jan 2019 17:14:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D68B8E0004; Thu, 31 Jan 2019 17:14:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF5A8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 17:14:54 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 202so3147663pgb.6
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:14:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K0avpk/hqoFnvobfNIzuoxWpN/+SehpNMMVRJ4661jU=;
        b=fgDdmJDtJnnoXiCHbuhD4Lx4DAb745RoTLAap2AGp+w9t9N6dhbMHG2hlm+Am8R44N
         4+zEh5At70+wHPfBbXib5dRwW33MNFNRajyEWYOww+owMRHbW4ayCC1L4Em9r6cp37z/
         gR02VirMiP3xOts2kcKGuYJcoD8Fu5YDY7uSCgWc4pYjQGqMlnoQhS1TJ76EWMpUHm3y
         PRwfCaEJXTUBEWJKIwd6Nfnzif8tpO5cQgw2iBcMoGMYv8u7Gs8jUHqDEuat0wevPzVR
         1XrYGGDP1dj+2q0MFLq5vZfKhzxcFMGm7BA7htBFF/Hr866mGw3PVz3jUz8ddXOqMxHp
         CBTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukebI19qE4mqYAyaHoplcTNHOaPEanjYpuai1QXxtSrMBuXklHLv
	Wn3cjC7IL1g3d0hxU6Z+EvO4Rq8IdiRmd2AyxpIiVCnJ4KPAWVhgD7ecdOv8v/fOxUoh0Bw2TMP
	BYOG8Lurv/wtTZR1L5q5AAGGOo38N9/iUu+ArJKQPsl2QFsPkSieJB+5TZcMVBPll+w==
X-Received: by 2002:a63:e516:: with SMTP id r22mr33830826pgh.256.1548972893729;
        Thu, 31 Jan 2019 14:14:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN47FZqcjQsfNGHTTb+0A0z+kKv9hSeeEN8LqLUTE0/Y7dmpDuO887YnF86d3Pl++UsDU+Ue
X-Received: by 2002:a63:e516:: with SMTP id r22mr33830787pgh.256.1548972893053;
        Thu, 31 Jan 2019 14:14:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548972893; cv=none;
        d=google.com; s=arc-20160816;
        b=GV6mSdYxEZ+C8y118UMqnPEisFGenMwD1+MjwLZfQtyf2T0JKqeX1qQFdkgvdMAFoS
         gk7MB85emdsChD+1PdagQDvnEfFdvQDjj5jKqDS+xylAUgBPp8fT9KfzuVn2tc1EtDFd
         i56xUPvJgZqbo2YT6rpk9ZSaXHcAp1uvcR12UV/d1DGrdm0BSo94E+xJfmv0igeOKnJc
         cY3n/kkLLlcI0LEH5rtrO3XxjV3QeII4RuRvfNJjVlVpkzkAdaecqqKFs6QERe3Dcv/y
         3xJ21BeZs6JiPLHhyTNW7Ldf6jbPiaDr0tuCwVNtqG+d8oLpvpDmnsVUxmJcoO+q41Nr
         x8xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=K0avpk/hqoFnvobfNIzuoxWpN/+SehpNMMVRJ4661jU=;
        b=YrlRZ+fEnw01MbV5eaHPr0VrPe02DH7JbS05v0sxPpzRg2AdaUKmLJttJxP5ScPjah
         88MuGdKD9h2BoMvGAcql7F4eRdOQc8QK5DEwvAHJcrNQEF3ouCoOE/vTGt32poZ/Cnrg
         vH1VZI9l2OaPwaKH1EEXInetcPFtLHSV151HWg74hh0QF517rLpGxcjD8pS5315qFrBy
         oVaE9pUgcLPfATUevnCEXtBH139YeMVNCiyzu1A9mJGbOplRAVRbe4ijypd/NzS33pmy
         se1xLVaqZfdv6wqBULU006HUZKQoEHuvFb+/hH3QYJlmBm2hdLIAs34Fwo48bYx+bVKK
         4txg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j66si5990125pfb.182.2019.01.31.14.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 14:14:53 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 75F3EE48;
	Thu, 31 Jan 2019 22:14:52 +0000 (UTC)
Date: Thu, 31 Jan 2019 14:14:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 3/3] mm: Maintain randomization of page free lists
Message-Id: <20190131141451.f60cdc434f97a31e3136ade4@linux-foundation.org>
In-Reply-To: <154882454628.1338686.46582179767934746.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
	<154882454628.1338686.46582179767934746.stgit@dwillia2-desk3.amr.corp.intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019 21:02:26 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> When freeing a page with an order >= shuffle_page_order randomly select
> the front or back of the list for insertion.
> 
> While the mm tries to defragment physical pages into huge pages this can
> tend to make the page allocator more predictable over time. Inject the
> front-back randomness to preserve the initial randomness established by
> shuffle_free_memory() when the kernel was booted.
> 
> The overhead of this manipulation is constrained by only being applied
> for MAX_ORDER sized pages by default.
> 
> 
> ...
>
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -98,6 +98,10 @@ extern int page_group_by_mobility_disabled;
>  struct free_area {
>  	struct list_head	free_list[MIGRATE_TYPES];
>  	unsigned long		nr_free;
> +#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
> +	u64			rand;
> +	u8			rand_bits;
> +#endif
>  };
>  
>  /* Used for pages not on another list */
> @@ -116,6 +120,14 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
>  	area->nr_free++;
>  }
>  
> +#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
> +/* Used to preserve page allocation order entropy */
> +void add_to_free_area_random(struct page *page, struct free_area *area,
> +		int migratetype);
> +#else
> +#define add_to_free_area_random add_to_free_area

A static inline would be nicer.

> +#endif
> +
>  /* Used for pages which are on another list */
>  static inline void move_to_free_area(struct page *page, struct free_area *area,
>  			     int migratetype)
> 
> ...
>
> --- a/mm/shuffle.c
> +++ b/mm/shuffle.c
> @@ -186,3 +186,19 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
>  	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
>  		shuffle_zone(z);
>  }
> +
> +void add_to_free_area_random(struct page *page, struct free_area *area,
> +		int migratetype)
> +{
> +	if (area->rand_bits == 0) {
> +		area->rand_bits = 64;
> +		area->rand = get_random_u64();
> +	}
> +
> +	if (area->rand & 1)
> +		add_to_free_area(page, area, migratetype);
> +	else
> +		add_to_free_area_tail(page, area, migratetype);
> +	area->rand_bits--;
> +	area->rand >>= 1;
> +}

Well that's nice and simple.

