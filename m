Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59E516B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:53:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so37884407wme.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:53:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jw2si4233987wjb.219.2016.04.27.05.53.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 05:53:25 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm, page_alloc: un-inline the bad part of
 free_pages_check
References: <5720A987.7060507@suse.cz>
 <1461758476-450-1-git-send-email-vbabka@suse.cz>
 <20160427123751.GI2858@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5720B643.6060908@suse.cz>
Date: Wed, 27 Apr 2016 14:53:23 +0200
MIME-Version: 1.0
In-Reply-To: <20160427123751.GI2858@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On 04/27/2016 02:37 PM, Mel Gorman wrote:
> On Wed, Apr 27, 2016 at 02:01:14PM +0200, Vlastimil Babka wrote:
>> !DEBUG_VM bloat-o-meter:
>>
>> add/remove: 1/0 grow/shrink: 0/2 up/down: 124/-383 (-259)
>> function                                     old     new   delta
>> free_pages_check_bad                           -     124    +124
>> free_pcppages_bulk                          1509    1403    -106
>> __free_pages_ok                             1025     748    -277
>>
>> DEBUG_VM:
>>
>> add/remove: 1/0 grow/shrink: 0/1 up/down: 124/-242 (-118)
>> function                                     old     new   delta
>> free_pages_check_bad                           -     124    +124
>> free_pages_prepare                          1048     806    -242
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>
> This uninlines the check all right but it also introduces new function
> calls into the free path. As it's the free fast path, I suspect it would
> be a step in the wrong direction from a performance perspective.

Oh expected this to be a non-issue as the call only happens when a bad 
page is actually encountered, which is rare? But if you can measure some 
overhead here then sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
