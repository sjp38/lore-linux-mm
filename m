Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E64A56B386C
	for <linux-mm@kvack.org>; Sat, 25 Aug 2018 22:21:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a26-v6so8475308pgw.7
        for <linux-mm@kvack.org>; Sat, 25 Aug 2018 19:21:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b25-v6si10799382pgf.545.2018.08.25.19.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 25 Aug 2018 19:21:15 -0700 (PDT)
Date: Sat, 25 Aug 2018 19:21:14 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1] tools/vm/slabinfo.c: fix sign-compare warning
Message-ID: <20180826022114.GA23206@bombadil.infradead.org>
References: <1535103134-20239-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535103134-20239-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Aug 24, 2018 at 06:32:14PM +0900, Naoya Horiguchi wrote:
> -	int hwcache_align, object_size, objs_per_slab;
> -	int sanity_checks, slab_size, store_user, trace;
> +	int hwcache_align, objs_per_slab;
> +	int sanity_checks, store_user, trace;
>  	int order, poison, reclaim_account, red_zone;
> +	unsigned int object_size, slab_size;

Surely hwcache_align and objs_per_slab can't be negative either?
Nor the other three.  So maybe convert all seven of these variables to
unsigned int?
