Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 964696B000D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 04:00:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s18-v6so1183900wmc.5
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 01:00:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h132-v6sor981040wmd.12.2018.08.08.01.00.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 01:00:51 -0700 (PDT)
Date: Wed, 8 Aug 2018 10:00:49 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180808080049.GC9568@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
 <20180807204834.GA6844@techadventures.net>
 <20180807221345.GD3301@redhat.com>
 <20180808073835.GA9568@techadventures.net>
 <24da07b9-5e06-af1d-42d3-c663eade16ea@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24da07b9-5e06-af1d-42d3-c663eade16ea@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 08, 2018 at 09:51:50AM +0200, David Hildenbrand wrote:
> > I am pretty sure this is a dumb question, but why HMM/devm path
> > do not call online_pages/offline_pages?
> 
> I think mainly because onlining/offlining (wild guesses)
> 
> - calls memory notifiers
> - works with memory blocks
> 
> (and does some more things not applicable to ZONE_DEVICE memory)

Yes, you are right.
They call arch_add_memory while want_memblock being false and so they do not
get to call hotplug_memory_register which handles all the memory block stuff.

Thanks
-- 
Oscar Salvador
SUSE L3
