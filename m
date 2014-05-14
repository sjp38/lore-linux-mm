Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3844B6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 05:01:17 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so1125476eek.2
        for <linux-mm@kvack.org>; Wed, 14 May 2014 02:01:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w2si1151750eel.206.2014.05.14.02.01.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 02:01:15 -0700 (PDT)
Message-ID: <537330D6.7040802@suse.cz>
Date: Wed, 14 May 2014 11:01:10 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list placement
 of CMA and RESERVE pages
References: <533D8015.1000106@suse.cz> <1396539618-31362-1-git-send-email-vbabka@suse.cz> <1396539618-31362-2-git-send-email-vbabka@suse.cz> <53616F39.2070001@oracle.com> <53638ADA.5040200@suse.cz> <5367A1E5.2020903@oracle.com> <5367B356.1030403@suse.cz> <5372E766.9040005@oracle.com> <alpine.LSU.2.11.1405132216560.4875@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1405132216560.4875@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On 05/14/2014 07:19 AM, Hugh Dickins wrote:
> On Tue, 13 May 2014, Sasha Levin wrote:
>> On 05/05/2014 11:50 AM, Vlastimil Babka wrote:
>>> So in the end this VM_DEBUG check probably cannot work anymore for MIGRATE_RESERVE, only for CMA. I'm not sure if it's worth keeping it only for CMA, what are the CMA guys' opinions on that?
>>
>> The way I understood it is that this patch is wrong, but it's still
>> alive in -mm. Should it still be there?
>
> I agree that it should be dropped.  I did not follow the discussion,
> but mmotm soon gives me BUG at mm/page_alloc.c:1242 under swapping load.

Yes, I have already asked for dropping, and updating message of PATCH 
1/2 at http://marc.info/?l=linux-mm&m=139947475413079&w=2

Vlastimil

> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
