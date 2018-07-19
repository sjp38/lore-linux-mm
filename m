Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D26076B000E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:59:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v25-v6so2461412wmc.8
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:59:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u185-v6sor1155483wmb.77.2018.07.19.06.59.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 06:59:00 -0700 (PDT)
Date: Thu, 19 Jul 2018 15:58:59 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 5/5] mm/page_alloc: Only call pgdat_set_deferred_range
 when the system boots
Message-ID: <20180719135859.GA10988@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-6-osalvador@techadventures.net>
 <20180719134622.GE7193@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719134622.GE7193@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu, Jul 19, 2018 at 03:46:22PM +0200, Michal Hocko wrote:
> On Thu 19-07-18 15:27:40, osalvador@techadventures.net wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > We should only care about deferred initialization when booting.
> 
> Again why is this worth doing?

Well, it is not a big win if that is what you meant.

Those two fields are only being used when dealing with deferred pages,
which only happens at boot time.

If later on, free_area_init_node gets called from memhotplug code,
we will also set the fields, although they will not be used.

Is this a problem? No, but I think it is more clear from the code if we
see when this is called.
So I would say it was only for code consistency.

If you think this this is not worth, I am ok with dropping it.

Thanks
-- 
Oscar Salvador
SUSE L3
