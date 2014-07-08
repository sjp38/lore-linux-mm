Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA8F900002
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 19:45:16 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8126739pab.18
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:45:15 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id zj8si44610658pac.125.2014.07.08.16.45.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 16:45:14 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so7944887pdj.19
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:45:14 -0700 (PDT)
Message-ID: <53BC8282.8080602@gmail.com>
Date: Wed, 09 Jul 2014 07:45:06 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: update the description for vm_total_pages
References: <53BB8553.10508@gmail.com> <20140708134136.597fbd11309d1e376eeb241c@linux-foundation.org>
In-Reply-To: <20140708134136.597fbd11309d1e376eeb241c@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org

Andrew,

On 2014a1'07ae??09ae?JPY 04:41, Andrew Morton wrote:
> On Tue, 08 Jul 2014 13:44:51 +0800 Wang Sheng-Hui <shhuiw@gmail.com> wrote:
> 
>>
>> vm_total_pages is calculated by nr_free_pagecache_pages(), which counts
>> the number of pages which are beyond the high watermark within all zones.
>> So vm_total_pages is not equal to total number of pages which the VM controls.
>>
>> ...
>>
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -136,7 +136,11 @@ struct scan_control {
>>   * From 0 .. 100.  Higher means more swappy.
>>   */
>>  int vm_swappiness = 60;
>> -unsigned long vm_total_pages;  /* The total number of pages which the VM controls */
>> +/*
>> + * The total number of pages which are beyond the high watermark
>> + * within all zones.
>> + */
>> +unsigned long vm_total_pages;
>>
>>  static LIST_HEAD(shrinker_list);
>>  static DECLARE_RWSEM(shrinker_rwsem);
> 
> Nice patch!  It's good to document these little things as one discovers
> them.
> 
> However vm_total_pages is only ever used in build_all_zonelists() and
> could be made a local within that function.

We can see that vm_total_pages is not used in build_all_zonelist() only.
          http://lxr.oss.org.cn/search?string=vm_total_pages

Maybe some redefinition is needed instead of current definition in vmscan.c.:-)

>

Regards,
Wang Sheng-Hui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
