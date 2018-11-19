Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6726B1C78
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 16:44:54 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so100382edz.15
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:44:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7-v6sor8374737ejf.34.2018.11.19.13.44.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 13:44:52 -0800 (PST)
Date: Mon, 19 Nov 2018 21:44:50 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181119214450.i6q7vpnbly4d6d3y@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
 <1542622061.3002.6.camel@suse.de>
 <20181119141505.xugul3s5nbzssybm@master>
 <20181119142325.GP22247@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119142325.GP22247@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, osalvador <osalvador@suse.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org

On Mon, Nov 19, 2018 at 03:23:25PM +0100, Michal Hocko wrote:
>On Mon 19-11-18 14:15:05, Wei Yang wrote:
>> On Mon, Nov 19, 2018 at 11:07:41AM +0100, osalvador wrote:
>> >
>> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> >
>> >Good catch.
>> >
>> >One thing I was wondering is that if we also should re-adjust it when a
>> >zone gets emptied during offlining memory.
>> >I checked, and whenever we work wirh pgdat->nr_zones we seem to check
>> >if the zone is populated in order to work with it.
>> >But still, I wonder if we should re-adjust it.
>> 
>> Well, thanks all for comments. I am glad you like it.
>> 
>> Actually, I have another proposal or I notice another potential issue.
>> 
>> In case user online pages in parallel, we may face a contention and get
>> a wrong nr_zones.
>
>No, this should be protected by the global mem hotplug lock. Anyway a
>dedicated lock would be much better. I would move it under
>pgdat_resize_lock.

This is what I think about.

Do you like me to send v2 with this change? Or you would like to add it
by yourself?

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
