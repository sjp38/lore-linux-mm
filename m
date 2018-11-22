Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1B26B2BA3
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 09:27:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so4554545edb.22
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 06:27:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f47sor13037907edb.4.2018.11.22.06.27.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 06:27:50 -0800 (PST)
Date: Thu, 22 Nov 2018 14:27:49 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
Message-ID: <20181122142749.ln77g62agblm6cwo@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
 <20181122101557.pzq6ggiymn52gfqk@master>
 <20181122102922.GE18011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122102922.GE18011@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Nov 22, 2018 at 11:29:22AM +0100, Michal Hocko wrote:
>On Thu 22-11-18 10:15:57, Wei Yang wrote:
>> On Thu, Nov 22, 2018 at 06:12:41PM +0800, Wei Yang wrote:
>> >During online_pages phase, pgdat->nr_zones will be updated in case this
>> >zone is empty.
>> >
>> >Currently the online_pages phase is protected by the global lock
>> >mem_hotplug_begin(), which ensures there is no contention during the
>> >update of nr_zones. But this global lock introduces scalability issues.
>> >
>> >This patch is a preparation for removing the global lock during
>> >online_pages phase. Also this patch changes the documentation of
>> >node_size_lock to include the protectioin of nr_zones.
>
>I would just add that the patch moves init_currently_empty_zone under
>both zone_span_writelock and pgdat_resize_lock because both the pgdat
>state is changed (nr_zones) and the zone's start_pfn
>
>> >
>> >Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> 
>> Missed this, if I am correct. :-)
>> 
>> Acked-by: Michal Hocko <mhocko@suse.com>
>
>Yes, thank you.

My pleasure :-)

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
