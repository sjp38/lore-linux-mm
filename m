Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0AB6B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 03:57:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k6so7498781wmi.6
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 00:57:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si1603640wre.77.2018.04.03.00.57.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 00:57:38 -0700 (PDT)
Date: Tue, 3 Apr 2018 09:57:37 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: call set_pageblock_order() once for each
 node
Message-ID: <20180403075737.GB5501@dhcp22.suse.cz>
References: <20180329033607.8440-1-richard.weiyang@gmail.com>
 <20180329121109.xg5tfk6dyqzkrgrh@suse.de>
 <20180330010243.GA14446@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180330010243.GA14446@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri 30-03-18 09:02:43, Wei Yang wrote:
> On Thu, Mar 29, 2018 at 01:11:09PM +0100, Mel Gorman wrote:
> >On Thu, Mar 29, 2018 at 11:36:07AM +0800, Wei Yang wrote:
> >> set_pageblock_order() is a standalone function which sets pageblock_order,
> >> while current implementation calls this function on each ZONE of each node
> >> in free_area_init_core().
> >> 
> >> Since free_area_init_node() is the only user of free_area_init_core(),
> >> this patch moves set_pageblock_order() up one level to invoke
> >> set_pageblock_order() only once on each node.
> >> 
> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> >
> >The patch looks ok but given that set_pageblock_order returns immediately
> >if it has already been called, I expect the benefit is marginal. Was any
> >improvement in boot time measured?
> 
> No, I don't expect measurable improvement from this since the number of nodes
> and zones are limited.
> 
> This is just a code refine from logic point of view.

Then, please make sure it is a real refinement. Calling this function
per node is only half way to get there as the function is by no means
per node.

-- 
Michal Hocko
SUSE Labs
