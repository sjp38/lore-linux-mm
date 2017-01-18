Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9556B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:29:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r126so2741431wmr.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:29:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14si125840wrb.263.2017.01.18.04.29.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 04:29:25 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] mm patches review bandwidth
References: <20170105153737.GV21618@dhcp22.suse.cz>
 <b1a870cc-608f-7613-c29f-9eb2a3518f8f@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1153b414-9992-0a6f-9a64-af4614363efd@suse.cz>
Date: Wed, 18 Jan 2017 13:29:22 +0100
MIME-Version: 1.0
In-Reply-To: <b1a870cc-608f-7613-c29f-9eb2a3518f8f@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

On 01/06/2017 02:43 AM, Mike Kravetz wrote:
> On 01/05/2017 07:37 AM, Michal Hocko wrote:
>> Another problem, somehow related, is that there are areas which have
>> evolved into a really bad shape because nobody has really payed
>> attention to them from the architectural POV when they were merged. To
>> name one the memory hotplug doesn't seem very healthy, full of kludges,
>> random hacks and fixes for fixes working for a particualr usecase
>> without any longterm vision. We have allowed to (ab)use concepts like
>> ZONE_MOVABLE which are finding new users because that seems to be the
>> simplest way forward. Now we are left with fixing the code which has
>> some fundamental issues because it is used out there. Are we going to do
>> anything about those? E.g. generate a list of them, discuss how to make
>> that code healthy again and do not allow new features until we sort that
>> out?
>
> hugetlb reservation processing seems to be one of those areas.  I certainly
> have been guilty of stretching the limits of the current code to meet the
> demands of new functionality.  It has been my desire to do some rewrite or
> rearchitecture in this area.

Since this is now a list, let me add cpuset's mems_allowed handling there... See 
[1] for some details.

[1] https://lkml.kernel.org/r/20170117221610.22505-1-vbabka@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
