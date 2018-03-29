Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 096016B0008
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 08:11:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u133so2562416wmf.4
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 05:11:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8si705266wmb.37.2018.03.29.05.11.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Mar 2018 05:11:11 -0700 (PDT)
Date: Thu, 29 Mar 2018 13:11:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/page_alloc: call set_pageblock_order() once for each
 node
Message-ID: <20180329121109.xg5tfk6dyqzkrgrh@suse.de>
References: <20180329033607.8440-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180329033607.8440-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Thu, Mar 29, 2018 at 11:36:07AM +0800, Wei Yang wrote:
> set_pageblock_order() is a standalone function which sets pageblock_order,
> while current implementation calls this function on each ZONE of each node
> in free_area_init_core().
> 
> Since free_area_init_node() is the only user of free_area_init_core(),
> this patch moves set_pageblock_order() up one level to invoke
> set_pageblock_order() only once on each node.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

The patch looks ok but given that set_pageblock_order returns immediately
if it has already been called, I expect the benefit is marginal. Was any
improvement in boot time measured?

-- 
Mel Gorman
SUSE Labs
