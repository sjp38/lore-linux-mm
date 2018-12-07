Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAD296B7FEF
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 04:54:52 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c34so1685419edb.8
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 01:54:52 -0800 (PST)
Subject: Re: [RFC Get rid of shrink code - memory-hotplug]
References: <72455c1d4347d263cb73517187bc1394@suse.de>
 <e167e2b9-f8b6-e322-b469-358096a97bda@redhat.com>
 <39aa34058fc9641346456463afc2082d@suse.de>
 <20181205191244.GV1286@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <42699b27-c214-91fd-e7e9-d34e16e9bf9f@suse.cz>
Date: Fri, 7 Dec 2018 10:54:50 +0100
MIME-Version: 1.0
In-Reply-To: <20181205191244.GV1286@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, osalvador@suse.de
Cc: David Hildenbrand <david@redhat.com>, dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On 12/5/18 8:12 PM, Michal Hocko wrote:
> [Cc Vlastimil]
> 
> On Tue 04-12-18 13:43:31, osalvador@suse.de wrote:
>> On 2018-12-04 12:31, David Hildenbrand wrote:
>>  > If I am not wrong, zone_contiguous is a pure mean for performance
>>> improvement, right? So leaving zone_contiguous unset is always save. I
>>> always disliked the whole clear/set_zone_contiguous thingy. I wonder if
>>> we can find a different way to boost performance there (in the general
>>> case). Or is this (zone_contiguous) even worth keeping around at all for
>>> now? (do we have performance numbers?)
>>
>> It looks like it was introduced by 7cf91a98e607
>> ("mm/compaction: speed up pageblock_pfn_to_page() when zone is contiguous").
>>
>> The improve numbers are in the commit.
>> So I would say that we need to keep it around.
> 
> Is that still the case though?

Well, __pageblock_pfn_to_page() has to be called for each pageblock in
compaction, when zone_contiguous is false. And that's unchanged since
the introduction of zone_contiguous, so the numbers should still hold.
