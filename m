Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4203F6B0038
	for <linux-mm@kvack.org>; Wed, 14 May 2014 01:21:15 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so1192351pab.24
        for <linux-mm@kvack.org>; Tue, 13 May 2014 22:21:14 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id er8si771461pad.81.2014.05.13.22.21.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 22:21:14 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so1210380pad.4
        for <linux-mm@kvack.org>; Tue, 13 May 2014 22:21:14 -0700 (PDT)
Date: Tue, 13 May 2014 22:19:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list placement
 of CMA and RESERVE pages
In-Reply-To: <5372E766.9040005@oracle.com>
Message-ID: <alpine.LSU.2.11.1405132216560.4875@eggly.anvils>
References: <533D8015.1000106@suse.cz> <1396539618-31362-1-git-send-email-vbabka@suse.cz> <1396539618-31362-2-git-send-email-vbabka@suse.cz> <53616F39.2070001@oracle.com> <53638ADA.5040200@suse.cz> <5367A1E5.2020903@oracle.com> <5367B356.1030403@suse.cz>
 <5372E766.9040005@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On Tue, 13 May 2014, Sasha Levin wrote:
> On 05/05/2014 11:50 AM, Vlastimil Babka wrote:
> > So in the end this VM_DEBUG check probably cannot work anymore for MIGRATE_RESERVE, only for CMA. I'm not sure if it's worth keeping it only for CMA, what are the CMA guys' opinions on that?
> 
> The way I understood it is that this patch is wrong, but it's still
> alive in -mm. Should it still be there?

I agree that it should be dropped.  I did not follow the discussion,
but mmotm soon gives me BUG at mm/page_alloc.c:1242 under swapping load.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
