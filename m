Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF79E8E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 04:55:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e17so716102edr.7
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 01:55:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k11-v6si2383258ejq.166.2019.01.23.01.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 01:55:05 -0800 (PST)
Date: Wed, 23 Jan 2019 10:55:03 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is
 not set
Message-ID: <20190123095503.GR4087@dhcp22.suse.cz>
References: <20190118234905.27597-1-richard.weiyang@gmail.com>
 <20190122085524.GE4087@dhcp22.suse.cz>
 <20190122150717.llf4owk6soejibov@master>
 <20190122151628.GI4087@dhcp22.suse.cz>
 <20190122155628.eu4sxocyjb5lrcla@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122155628.eu4sxocyjb5lrcla@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Tue 22-01-19 15:56:28, Wei Yang wrote:
> On Tue, Jan 22, 2019 at 04:16:28PM +0100, Michal Hocko wrote:
> >On Tue 22-01-19 15:07:17, Wei Yang wrote:
> >> On Tue, Jan 22, 2019 at 09:55:24AM +0100, Michal Hocko wrote:
> >> >On Sat 19-01-19 07:49:05, Wei Yang wrote:
> >> >> Two cleanups in this patch:
> >> >> 
> >> >>   * since pageblock_nr_pages == (1 << pageblock_order), the roundup()
> >> >>     and right shift pageblock_order could be replaced with
> >> >>     DIV_ROUND_UP()
> >> >
> >> >Why is this change worth it?
> >> >
> >> 
> >> To make it directly show usemapsize is number of times of
> >> pageblock_nr_pages.
> >
> >Does this lead to a better code generation? Does it make the code easier
> >to read/maintain?
> >
> 
> I think the answer is yes.
> 
>   * it reduce the code from 6 lines to 3 lines, 50% off
>   * by reducing calculation back and forth, it would be easier for
>     audience to catch what it tries to do

To be honest, I really do not see this sufficient to justify touching
the code unless the resulting _generated_ code is better/more efficient.
-- 
Michal Hocko
SUSE Labs
