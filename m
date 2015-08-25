Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF436B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:47:07 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so14755965wid.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 05:47:07 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id kf4si3066602wic.48.2015.08.25.05.47.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 05:47:03 -0700 (PDT)
Date: Tue, 25 Aug 2015 14:46:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150825124655.GQ16853@twins.programming.kicks-ass.net>
References: <20150823060443.GA9882@gmail.com>
 <20150823064603.14050.qmail@ns.horizon.com>
 <20150823081750.GA28349@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150823081750.GA28349@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

On Sun, Aug 23, 2015 at 10:17:51AM +0200, Ingo Molnar wrote:
> +static u64 vmap_info_gen;
> +static u64 vmap_info_cache_gen;

> +void get_vmalloc_info(struct vmalloc_info *vmi)
> +{
> +	u64 gen = READ_ONCE(vmap_info_gen);
> +
> +	/*
> +	 * If the generation counter of the cache matches that of
> +	 * the vmalloc generation counter then return the cache:
> +	 */
> +	if (READ_ONCE(vmap_info_cache_gen) == gen) {

Why are those things u64? It has the obvious down-side that you still
get split loads on 32bit machines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
