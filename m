Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7616B000D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 07:52:57 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z13-v6so14481793wrq.3
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 04:52:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor7298610wrm.62.2018.08.01.04.52.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 04:52:56 -0700 (PDT)
Date: Wed, 1 Aug 2018 13:52:54 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 4/4] mm/page_alloc: Introduce
 free_area_init_core_hotplug
Message-ID: <20180801115254.GA7145@techadventures.net>
References: <20180730101757.28058-1-osalvador@techadventures.net>
 <20180730101757.28058-5-osalvador@techadventures.net>
 <20180801114726.GL16767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180801114726.GL16767@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 01, 2018 at 01:47:26PM +0200, Michal Hocko wrote:
> 
> The split up makes sense to me. Sections attributes can be handled on
> top. Btw. free_area_init_core_hotplug declaration could have gone into
> include/linux/memory_hotplug.h to save the ifdef

You are right, I will fix this up.

> 
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks Michal!

Since Pavel and I agreed on putting a patch of his which removes __paginginit
into this patchset, I will send out a v6 in a few minutes.

-- 
Oscar Salvador
SUSE L3
