Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03C1B44088B
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 03:57:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o201so1423403wmg.15
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 00:57:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si5032791wrc.161.2017.08.25.00.57.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 00:57:13 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
References: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
 <e919c65e-bc2f-6b3b-41fc-3589590a84ac@suse.cz>
 <20170825002031.GD29701@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d57eeb5c-d91d-9718-8473-3c6db465b154@suse.cz>
Date: Fri, 25 Aug 2017 09:56:10 +0200
MIME-Version: 1.0
In-Reply-To: <20170825002031.GD29701@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/25/2017 02:20 AM, Joonsoo Kim wrote:
> On Thu, Aug 24, 2017 at 11:41:58AM +0200, Vlastimil Babka wrote:
> 
> Hmm, this is already pointed by Minchan and I have answered that.
> 
> lkml.kernel.org/r/<20170421013243.GA13966@js1304-desktop>
> 
> If you have a better idea, please let me know.

My idea is that size of sysctl_lowmem_reserve_ratio is ZONE_NORMAL+1 and
it has no entries for zones > NORMAL. The
setup_per_zone_lowmem_reserve() is adjusted to only set
lower_zone->lowmem_reserve[j] for idx <= ZONE_NORMAL.

I can't imagine somebody would want override the ratio for HIGHMEM or
MOVABLE
(where it has no effect anyway) so the simplest thing is not to expose
it at all.

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
