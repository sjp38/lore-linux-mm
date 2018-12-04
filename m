Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 77A0D6B6EA7
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 07:43:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o21so8189565edq.4
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 04:43:33 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 04 Dec 2018 13:43:31 +0100
From: osalvador@suse.de
Subject: Re: [RFC Get rid of shrink code - memory-hotplug]
In-Reply-To: <e167e2b9-f8b6-e322-b469-358096a97bda@redhat.com>
References: <72455c1d4347d263cb73517187bc1394@suse.de>
 <e167e2b9-f8b6-e322-b469-358096a97bda@redhat.com>
Message-ID: <39aa34058fc9641346456463afc2082d@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: mhocko@suse.com, dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On 2018-12-04 12:31, David Hildenbrand wrote:
  > If I am not wrong, zone_contiguous is a pure mean for performance
> improvement, right? So leaving zone_contiguous unset is always save. I
> always disliked the whole clear/set_zone_contiguous thingy. I wonder if
> we can find a different way to boost performance there (in the general
> case). Or is this (zone_contiguous) even worth keeping around at all 
> for
> now? (do we have performance numbers?)

It looks like it was introduced by 7cf91a98e607
("mm/compaction: speed up pageblock_pfn_to_page() when zone is 
contiguous").

The improve numbers are in the commit.
So I would say that we need to keep it around.


> I'd say let's give it a try and find out if we are missing something. 
> +1
> to simplifying that code.

I will work on a patch removing this and I will integrate it in [1].
Then I will run some tests to see if I can catch something bad.

[1] https://patchwork.kernel.org/cover/10700783/

Thanks for taking a look!

Oscar Salvador
