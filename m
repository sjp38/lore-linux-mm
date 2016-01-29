Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id E0A316B0255
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 16:21:49 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id k206so55625650oia.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:21:49 -0800 (PST)
Received: from alln-iport-6.cisco.com (alln-iport-6.cisco.com. [173.37.142.93])
        by mx.google.com with ESMTPS id r81si16326178oib.117.2016.01.29.13.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 13:21:49 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
 <56AABA79.3030103@cisco.com> <56AAC085.9060509@cisco.com>
 <20160129015534.GA6401@cmpxchg.org>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56ABD7EB.7000404@cisco.com>
Date: Fri, 29 Jan 2016 13:21:47 -0800
MIME-Version: 1.0
In-Reply-To: <20160129015534.GA6401@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, Rik van Riel <riel@redhat.com>

On 01/28/2016 05:55 PM, Johannes Weiner wrote:
> On Thu, Jan 28, 2016 at 05:29:41PM -0800, Daniel Walker wrote:
>> On 01/28/2016 05:03 PM, Daniel Walker wrote:
>> [regarding MemAvaiable]
>>
>> This new metric purportedly helps usrespace assess available memory. But,
>> its again based on heuristic, it takes 1/2 of page cache as reclaimable..
> No, it takes the smaller value of cache/2 and the low watermark, which
> is a fraction of memory. Actually, that does look a little weird. Rik?
>
> We don't age cache without memory pressure, you don't know how much is
> used until you start taking some away. Heuristics is all we can offer.

With a simple busybox root system I get this,

MemTotal:          16273996 kB
MemFree:          16137920 kB
MemAvailable:   16046132 kB

shouldn't MemAvailable be at least the same as MemFree ? I changed the 
code somewhat so it subtracted the wmark_low only, or the pagecache/2 
only, both are still under MemFree. This system has very little 
drop-able caches.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
