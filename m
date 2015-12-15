Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0856B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 03:24:18 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so13814666wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 00:24:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a83si31227367wmd.86.2015.12.15.00.24.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Dec 2015 00:24:17 -0800 (PST)
Subject: Re: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when
 zone is contiguous
References: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1450069341-28875-2-git-send-email-iamjoonsoo.kim@lge.com>
 <566E9A21.9000503@suse.cz>
 <CAAmzW4P++gjVtcGw9PiMZu2kk80_v=jFjCPis7hbxLXmLNedUg@mail.gmail.com>
 <566F677C.20701@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <566FCE2E.7050301@suse.cz>
Date: Tue, 15 Dec 2015 09:24:14 +0100
MIME-Version: 1.0
In-Reply-To: <566F677C.20701@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/15/2015 02:06 AM, Aaron Lu wrote:
> On 12/14/2015 11:25 PM, Joonsoo Kim wrote:
>> 2015-12-14 19:29 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>>> Unless I'm mistaken, these results also include my RFC series (Aaron can you
>>> clarify?). These patches should better be tested standalone on top of base,
>>> as being simpler they will probably be included sooner (the RFC series needs
>>> reviews at the very least :) - although the memory hotplug concerns might
>>> make the "sooner" here relative too.
>>
>> AFAIK, these patches are tested standalone on top of base. When I sent it,
>> I asked to Aaron to test it on top of base.
>
> Right, it is tested standalone on top of base.

Thanks, sorry about the noise then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
