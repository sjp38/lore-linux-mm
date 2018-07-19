Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB296B026A
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:03:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w10-v6so3304065eds.7
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:03:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4-v6si4083668edq.426.2018.07.19.07.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 07:03:11 -0700 (PDT)
Date: Thu, 19 Jul 2018 16:03:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/5] mm/page_alloc: Only call pgdat_set_deferred_range
 when the system boots
Message-ID: <20180719140308.GG7193@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-6-osalvador@techadventures.net>
 <20180719134622.GE7193@dhcp22.suse.cz>
 <20180719135859.GA10988@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719135859.GA10988@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu 19-07-18 15:58:59, Oscar Salvador wrote:
> On Thu, Jul 19, 2018 at 03:46:22PM +0200, Michal Hocko wrote:
> > On Thu 19-07-18 15:27:40, osalvador@techadventures.net wrote:
> > > From: Oscar Salvador <osalvador@suse.de>
> > > 
> > > We should only care about deferred initialization when booting.
> > 
> > Again why is this worth doing?
> 
> Well, it is not a big win if that is what you meant.
> 
> Those two fields are only being used when dealing with deferred pages,
> which only happens at boot time.
> 
> If later on, free_area_init_node gets called from memhotplug code,
> we will also set the fields, although they will not be used.
> 
> Is this a problem? No, but I think it is more clear from the code if we
> see when this is called.
> So I would say it was only for code consistency.

Then put it to the changelog.

> If you think this this is not worth, I am ok with dropping it.

I am not really sure. I am not a big fan of SYSTEM_BOOTING global
thingy so I would rather not spread its usage.
-- 
Michal Hocko
SUSE Labs
