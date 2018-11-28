Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EADE6B4D17
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 08:08:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so12133066edm.18
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 05:08:27 -0800 (PST)
Date: Wed, 28 Nov 2018 14:08:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
Message-ID: <20181128130824.GL6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz>
 <1543388866.2920.5.camel@suse.de>
 <20181128101426.GH6923@dhcp22.suse.cz>
 <ddee6546c35aaada14b196c83f5205e0@suse.de>
 <20181128123120.GJ6923@dhcp22.suse.cz>
 <ddd7474af7162dcfa3ce328587b4a916@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddd7474af7162dcfa3ce328587b4a916@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On Wed 28-11-18 13:51:42, osalvador@suse.de wrote:
> > yep. Or when we extend a zone/node via hotplug.
> > 
> > > The only thing I am worried about is that by doing that, the system
> > > will account spanned_pages incorrectly.
> > 
> > As long as end_pfn - start_pfn matches then I do not see what would be
> > incorrect.
> 
> If by end_pfn - start_pfn you mean zone_end_pfn - zone_start_pfn,
> then we would still need to change zone_start_pfn when removing
> the first section, and adjust spanned_pages in case we remove the last
> section,
> would not we?

Why? Again, how is removing the last/first section of the zone any
different from any other section?
-- 
Michal Hocko
SUSE Labs
