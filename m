Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0106B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:20:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h24-v6so8006114ede.9
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:20:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z15-v6sor5221963eju.2.2018.11.14.00.20.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 00:20:49 -0800 (PST)
Date: Wed, 14 Nov 2018 08:20:47 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181114082047.tenvzvorifd56emd@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
 <20181112080926.GA14987@dhcp22.suse.cz>
 <20181112142641.6oxn4fv4pocm7fmt@master>
 <20181112144020.GC14987@dhcp22.suse.cz>
 <20181113013942.zgixlky4ojbzikbd@master>
 <20181113080834.GK15120@dhcp22.suse.cz>
 <20181113081644.giu5vxhsfqjqlexh@master>
 <20181113090758.GL15120@dhcp22.suse.cz>
 <20181114074341.r53rukmj25ydvaqi@master>
 <20181114074821.GE23419@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114074821.GE23419@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Wed, Nov 14, 2018 at 08:48:21AM +0100, Michal Hocko wrote:
>On Wed 14-11-18 07:43:41, Wei Yang wrote:
>> On Tue, Nov 13, 2018 at 10:07:58AM +0100, Michal Hocko wrote:
>> >On Tue 13-11-18 08:16:44, Wei Yang wrote:
>> >
>> >No, I believe we want all three of them. But reviewing
>> >for_each_populated_zone users and explicit checks for present/managed
>> >pages and unify them would be a step forward both a more optimal code
>> >and more maintainable code. I haven't checked but
>> >for_each_populated_zone would seem like a proper user for managed page
>> >counter. But that really requires to review all current users.
>> >
>> 
>> To sync with your purpose, I searched the user of
>> for_each_populated_zone() and replace it with a new loop
>> for_each_managed_zone().
>
>I do not think we really want a new iterator. Is there any users of
>for_each_populated_zone which would be interested in something else than
>managed pages?

Your purpose is replace the populated_zone() in
for_each_populated_zone() with managed_zone()?

If this is the case, most of them is possible. Some places I am not sure
is:

    kernel/power/snapshot.c
    mm/huge_memory.c
    mm/khugepaged.c

For other places, I thinks it is ok to replace it.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
