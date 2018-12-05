Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7A826B75E1
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 14:12:47 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e29so10479674ede.19
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 11:12:47 -0800 (PST)
Date: Wed, 5 Dec 2018 20:12:44 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC Get rid of shrink code - memory-hotplug]
Message-ID: <20181205191244.GV1286@dhcp22.suse.cz>
References: <72455c1d4347d263cb73517187bc1394@suse.de>
 <e167e2b9-f8b6-e322-b469-358096a97bda@redhat.com>
 <39aa34058fc9641346456463afc2082d@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39aa34058fc9641346456463afc2082d@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: David Hildenbrand <david@redhat.com>, dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org, owner-linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

[Cc Vlastimil]

On Tue 04-12-18 13:43:31, osalvador@suse.de wrote:
> On 2018-12-04 12:31, David Hildenbrand wrote:
>  > If I am not wrong, zone_contiguous is a pure mean for performance
> > improvement, right? So leaving zone_contiguous unset is always save. I
> > always disliked the whole clear/set_zone_contiguous thingy. I wonder if
> > we can find a different way to boost performance there (in the general
> > case). Or is this (zone_contiguous) even worth keeping around at all for
> > now? (do we have performance numbers?)
> 
> It looks like it was introduced by 7cf91a98e607
> ("mm/compaction: speed up pageblock_pfn_to_page() when zone is contiguous").
> 
> The improve numbers are in the commit.
> So I would say that we need to keep it around.

Is that still the case though?

-- 
Michal Hocko
SUSE Labs
