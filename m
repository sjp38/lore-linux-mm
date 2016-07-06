Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03500828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 14:13:04 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id b13so468030349pat.3
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 11:13:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id c10si5174410pan.75.2016.07.06.11.13.02
        for <linux-mm@kvack.org>;
        Wed, 06 Jul 2016 11:13:02 -0700 (PDT)
Subject: Re: [PATCH 31/31] mm, vmstat: Remove zone and node double accounting
 by approximating retries
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-32-git-send-email-mgorman@techsingularity.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <577D4A24.1090800@intel.com>
Date: Wed, 6 Jul 2016 11:12:52 -0700
MIME-Version: 1.0
In-Reply-To: <1467403299-25786-32-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 07/01/2016 01:01 PM, Mel Gorman wrote:
> +#ifdef CONFIG_HIGHMEM
> +extern unsigned long highmem_file_pages;
> +
> +static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
> +							int nr_pages)
> +{
> +	if (is_highmem_idx(zid) && is_file_lru(lru))
> +		highmem_file_pages += nr_pages;
> +}
> +#else

Shouldn't highmem_file_pages technically be an atomic_t (or atomic64_t)?
 We could have highmem on two nodes which take two different LRU locks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
