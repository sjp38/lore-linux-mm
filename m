Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 718566B58DE
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 16:45:46 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k96-v6so9486406wrc.3
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 13:45:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z78-v6sor6735784wrb.45.2018.08.31.13.45.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 13:45:45 -0700 (PDT)
Date: Fri, 31 Aug 2018 22:45:43 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm/page_alloc: Clean up check_for_memory
Message-ID: <20180831204543.GA3885@techadventures.net>
References: <20180828210158.4617-1-osalvador@techadventures.net>
 <332d9ea1-cdd0-6bb6-8e83-28af25096637@microsoft.com>
 <20180831122401.GA2123@techadventures.net>
 <b2fea9ef-84e9-84dc-c847-5b944a8d832f@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b2fea9ef-84e9-84dc-c847-5b944a8d832f@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On Fri, Aug 31, 2018 at 02:04:59PM +0000, Pasha Tatashin wrote:
> Are you saying the code that is in mainline is broken? Because we set
> node_set_state(nid, N_NORMAL_MEMORY); even on node with N_HIGH_MEMORY:
> 
> 6826			if (N_NORMAL_MEMORY != N_HIGH_MEMORY &&
> 6827			    zone_type <= ZONE_NORMAL)
> 6828				node_set_state(nid, N_NORMAL_MEMORY);

Yes, and that is fine. Although the curent code is subtle for the reasons
I expplained in the changelog.
What I am saying is that the code you suggested would not work
because your code either sets N_NORMAL_MEMORY or N_HIGH_MEMORY and then
breaks the loop.

That is wrong because when we are on a CONFIG_HIGHMEM system,
it can happen that we have a node with both types, so we have to set
both types of memory.

N_HIGH_MEMORY, and N_NORMAL_MEMORY if the zone is <= ZONE_NORMAL.

Thanks
-- 
Oscar Salvador
SUSE L3
