Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8457F6B000A
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 08:29:15 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j6-v6so7391755wrr.15
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 05:29:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2-v6sor7067434wrv.58.2018.08.01.05.29.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 05:29:14 -0700 (PDT)
Date: Wed, 1 Aug 2018 14:29:12 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 4/4] mm/page_alloc: Introduce
 free_area_init_core_hotplug
Message-ID: <20180801122912.GC473@techadventures.net>
References: <20180730101757.28058-1-osalvador@techadventures.net>
 <20180730101757.28058-5-osalvador@techadventures.net>
 <20180731101752.GA473@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180731101752.GA473@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

On Tue, Jul 31, 2018 at 12:17:52PM +0200, Oscar Salvador wrote:
> On Mon, Jul 30, 2018 at 12:17:57PM +0200, osalvador@techadventures.net wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> ...
> > Also, since free_area_init_core/free_area_init_node will now only get called during early init, let us replace
> > __paginginit with __init, so their code gets freed up.
> > 
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> Andrew, could you please fold the following cleanup into this patch?
> thanks

Hi Andrew,

I sent v6, which already includes that cleanup-fixup plus another patch from Pavel and
an Acked-by from Michal Hocko.
So if it looks fine to you, feel free to replace it with the version that is sitting right now in -mm (v5)
 
Thanks
-- 
Oscar Salvador
SUSE L3
