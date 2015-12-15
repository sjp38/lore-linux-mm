Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 81DAB6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 20:06:11 -0500 (EST)
Received: by pabur14 with SMTP id ur14so113274739pab.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 17:06:11 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id kr7si12391982pab.120.2015.12.14.17.06.10
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 17:06:10 -0800 (PST)
Subject: Re: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when
 zone is contiguous
References: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1450069341-28875-2-git-send-email-iamjoonsoo.kim@lge.com>
 <566E9A21.9000503@suse.cz>
 <CAAmzW4P++gjVtcGw9PiMZu2kk80_v=jFjCPis7hbxLXmLNedUg@mail.gmail.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <566F677C.20701@intel.com>
Date: Tue, 15 Dec 2015 09:06:04 +0800
MIME-Version: 1.0
In-Reply-To: <CAAmzW4P++gjVtcGw9PiMZu2kk80_v=jFjCPis7hbxLXmLNedUg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/14/2015 11:25 PM, Joonsoo Kim wrote:
> 2015-12-14 19:29 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>> On 12/14/2015 06:02 AM, Joonsoo Kim wrote:
>>> Before vs After
>>> Max: 1096 MB/s vs 1325 MB/s
>>> Min: 635 MB/s 1015 MB/s
>>> Avg: 899 MB/s 1194 MB/s
>>>
>>> Avg is improved by roughly 30% [2].
>>
>>
>> Unless I'm mistaken, these results also include my RFC series (Aaron can you
>> clarify?). These patches should better be tested standalone on top of base,
>> as being simpler they will probably be included sooner (the RFC series needs
>> reviews at the very least :) - although the memory hotplug concerns might
>> make the "sooner" here relative too.
> 
> AFAIK, these patches are tested standalone on top of base. When I sent it,
> I asked to Aaron to test it on top of base.

Right, it is tested standalone on top of base.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
