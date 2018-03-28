Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71A356B0031
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:02:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o23so680001wrc.9
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 00:02:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n74si2246965wmg.69.2018.03.28.00.02.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 00:02:01 -0700 (PDT)
Date: Wed, 28 Mar 2018 09:02:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: break on the first hit of mem range
Message-ID: <20180328070200.GC9275@dhcp22.suse.cz>
References: <20180327035707.84113-1-richard.weiyang@gmail.com>
 <20180327105821.GF5652@dhcp22.suse.cz>
 <20180328003936.GB91956@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180328003936.GB91956@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Wed 28-03-18 08:39:36, Wei Yang wrote:
> On Tue, Mar 27, 2018 at 12:58:21PM +0200, Michal Hocko wrote:
> >On Tue 27-03-18 11:57:07, Wei Yang wrote:
> >> find_min_pfn_for_node() iterate on pfn range to find the minimum pfn for a
> >> node. The memblock_region in memblock_type are already ordered, which means
> >> the first hit in iteration is the minimum pfn.
> >
> >I haven't looked at the code yet but the changelog should contain the
> >motivation why it exists. It seems like this is an optimization. If so,
> >what is the impact?
> >
> 
> Yep, this is a trivial optimization on searching the minimal pfn on a special
> node. It would be better for audience to understand if I put some words in
> change log.
> 
> The impact of this patch is it would accelerate the searching process when
> there are many memory ranges in memblock.
> 
> For example, in the case https://lkml.org/lkml/2018/3/25/291, there are around
> 30 memory ranges on node 0. The original code need to iterate all those ranges
> to find the minimal pfn, while after optimization it just need once.

Then show us some numbers to justify the change.
-- 
Michal Hocko
SUSE Labs
