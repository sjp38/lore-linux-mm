Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F22DA6B4B9A
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 01:50:21 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w2so11707487edc.13
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 22:50:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10-v6si3386862ejo.126.2018.11.27.22.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 22:50:20 -0800 (PST)
Date: Wed, 28 Nov 2018 07:50:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
Message-ID: <20181128065018.GG6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127162005.15833-6-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>

On Tue 27-11-18 17:20:05, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.com>
> 
> shrink_zone_span and shrink_pgdat_span look a bit weird.
> 
> They both have a loop at the end to check if the zone
> or pgdat contains only holes in case the section to be removed
> was not either the first one or the last one.
> 
> Both code loops look quite similar, so we can simplify it a bit.
> We do that by creating a function (has_only_holes), that basically
> calls find_smallest_section_pfn() with the full range.
> In case nothing has to be found, we do not have any more sections
> there.
> 
> To be honest, I am not really sure we even need to go through this
> check in case we are removing a middle section, because from what I can see,
> we will always have a first/last section.
> 
> Taking the chance, we could also simplify both find_smallest_section_pfn()
> and find_biggest_section_pfn() functions and move the common code
> to a helper.

I didn't get to read through this whole series but one thing that is on
my todo list for a long time is to remove all this stuff. I do not think
we really want to simplify it when there shouldn't be any real reason to
have it around at all. Why do we need to shrink zone/node at all?

Now that we can override and assign memory to both normal na movable
zones I think we should be good to remove shrinking.

-- 
Michal Hocko
SUSE Labs
