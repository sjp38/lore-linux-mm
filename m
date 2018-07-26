Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE89F6B0008
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:12:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y18-v6so629108wma.9
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:12:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 79-v6sor210647wme.33.2018.07.26.01.12.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 01:12:16 -0700 (PDT)
Date: Thu, 26 Jul 2018 10:12:15 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
Message-ID: <20180726081215.GC22028@techadventures.net>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-3-osalvador@techadventures.net>
 <20180726080500.GX28386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726080500.GX28386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

On Thu, Jul 26, 2018 at 10:05:00AM +0200, Michal Hocko wrote:
> On Thu 26-07-18 00:01:41, osalvador@techadventures.net wrote:
> > From: Pavel Tatashin <pasha.tatashin@oracle.com>
> > 
> > zone->node is configured only when CONFIG_NUMA=y, so it is a good idea to
> > have inline functions to access this field in order to avoid ifdef's in
> > c files.
> > 
> > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > Reviewed-by: Oscar Salvador <osalvador@suse.de>
> 
> My previous [1] question is not addressed in the changelog but I will
> not insist. If there is any reason to resubmit this then please
> consider.

Oh, sorry, I missed that.
If I resubmit a new version, I can include the information about
opengrok, although it would be better if Pavel comments on it,
as I have no clue about the software.

If not, maybe Andrew can grab it?

Thanks
-- 
Oscar Salvador
SUSE L3
