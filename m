Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7F66B04DA
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:48:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r63-v6so2569912pfl.12
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:48:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c2-v6si5325318pfh.215.2018.05.17.04.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 May 2018 04:48:23 -0700 (PDT)
Date: Thu, 17 May 2018 04:48:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v3 PATCH 1/5] mm/page_alloc: use helper functions to
 add/remove a page to/from buddy
Message-ID: <20180517114821.GA26689@bombadil.infradead.org>
References: <20180509085450.3524-1-aaron.lu@intel.com>
 <20180509085450.3524-2-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509085450.3524-2-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>

On Wed, May 09, 2018 at 04:54:46PM +0800, Aaron Lu wrote:
> +static inline void add_to_buddy_head(struct page *page, struct zone *zone,
> +					unsigned int order, int mt)
> +{
> +	add_to_buddy_common(page, zone, order);
> +	list_add(&page->lru, &zone->free_area[order].free_list[mt]);
> +}

Isn't this function (and all of its friends) misnamed?  We're not adding
this page to the buddy allocator, we're adding it to the freelist.  It
doesn't go to the buddy allocator until later, if at all.
