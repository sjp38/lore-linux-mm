Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id CB3DC6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 01:15:48 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa11so106258pad.27
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 22:15:47 -0700 (PDT)
Message-ID: <5164F57E.3030106@gmail.com>
Date: Wed, 10 Apr 2013 13:15:42 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: page_alloc: Avoid marking zones full prematurely
 after zone_reclaim()
References: <20130320181957.GA1878@suse.de> <514A7163.5070700@gmail.com> <20130321081902.GD6094@dhcp22.suse.cz> <515E6FC4.5000202@gmail.com> <5163E7EA.1040608@gmail.com> <20130409101437.GE29860@dhcp22.suse.cz>
In-Reply-To: <20130409101437.GE29860@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Simon Jeons <simon.jeons@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hedi Berriche <hedi@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Michal,
On 04/09/2013 06:14 PM, Michal Hocko wrote:
> On Tue 09-04-13 18:05:30, Simon Jeons wrote:
> [...]
>>> I try this in v3.9-rc5:
>>> dd if=/dev/sda of=/dev/null bs=1MB
>>> 14813+0 records in
>>> 14812+0 records out
>>> 14812000000 bytes (15 GB) copied, 105.988 s, 140 MB/s
>>>
>>> free -m -s 1
>>>
>>>                    total       used       free     shared buffers
>>> cached
>>> Mem:          7912       1181       6731          0 663        239
>>> -/+ buffers/cache:        277       7634
>>> Swap:         8011          0       8011
>>>
>>> It seems that almost 15GB copied before I stop dd, but the used
>>> pages which I monitor during dd always around 1200MB. Weird, why?
>>>
>> Sorry for waste your time, but the test result is weird, is it?
> I am not sure which values you have been watching but you have to
> realize that you are reading a _partition_ not a file and those pages
> go into buffers rather than the page chache.

Interesting. ;-)

What's the difference between buffers and page cache? Why buffers don't 
grow?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
