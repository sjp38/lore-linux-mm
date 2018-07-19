Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F2C5C6B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:19:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f13-v6so2359609wmb.4
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:19:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b67-v6sor1324192wme.65.2018.07.19.05.19.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 05:19:03 -0700 (PDT)
Date: Thu, 19 Jul 2018 14:19:02 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 1/3] mm/page_alloc: Move ifdefery out of
 free_area_init_core
Message-ID: <20180719121902.GB8750@techadventures.net>
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

Hi Pavel,

I am about to send v2 with this patch included, but I just wanted to let you know
this:

> +		zone_set_nid(nid);

This should be:

zone_set_nid(zone, nid);

I fixed it up in your patch, I hope that is ok.

Thanks 
-- 
Oscar Salvador
SUSE L3
