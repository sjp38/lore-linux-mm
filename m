Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5200B6B000C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:15:53 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v2-v6so2051914wrr.10
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:15:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s3-v6sor1836389wrm.1.2018.07.18.08.15.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 08:15:52 -0700 (PDT)
Date: Wed, 18 Jul 2018 17:15:50 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 1/3] mm/page_alloc: Move ifdefery out of
 free_area_init_core
Message-ID: <20180718151550.GA2985@techadventures.net>
References: <20180718124722.9872-1-osalvador@techadventures.net>
 <20180718124722.9872-2-osalvador@techadventures.net>
 <20180718141150.imiyuust5txfmfvw@xakep.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718141150.imiyuust5txfmfvw@xakep.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Wed, Jul 18, 2018 at 10:11:50AM -0400, Pavel Tatashin wrote:
> On 18-07-18 14:47:20, osalvador@techadventures.net wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > Moving the #ifdefs out of the function makes it easier to follow.
> > 
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> 
> Hi Oscar,
> 
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> Please include the following patch in your series, to get rid of the last
> ifdef in this function.
> 
> From f841184e141b21e79c4d017d3b7678c697016d2a Mon Sep 17 00:00:00 2001
> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> Date: Wed, 18 Jul 2018 09:56:52 -0400
> Subject: [PATCH] mm: access zone->node via zone_to_nid() and zone_set_nid()
> 
> zone->node is configured only when CONFIG_NUMA=y, so it is a good idea to
> have inline functions to access this field in order to avoid ifdef's in
> c files.

Hi Pavel

I will! Thanks for the patch ;-)
-- 
Oscar Salvador
SUSE L3
