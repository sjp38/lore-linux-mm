Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 472B06B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 23:48:12 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1111258pad.30
        for <linux-mm@kvack.org>; Tue, 13 May 2014 20:48:11 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ko6si264996pbc.485.2014.05.13.20.48.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 20:48:11 -0700 (PDT)
Message-ID: <5372E766.9040005@oracle.com>
Date: Tue, 13 May 2014 23:47:50 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list placement
 of CMA and RESERVE pages
References: <533D8015.1000106@suse.cz> <1396539618-31362-1-git-send-email-vbabka@suse.cz> <1396539618-31362-2-git-send-email-vbabka@suse.cz> <53616F39.2070001@oracle.com> <53638ADA.5040200@suse.cz> <5367A1E5.2020903@oracle.com> <5367B356.1030403@suse.cz>
In-Reply-To: <5367B356.1030403@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On 05/05/2014 11:50 AM, Vlastimil Babka wrote:
> So in the end this VM_DEBUG check probably cannot work anymore for MIGRATE_RESERVE, only for CMA. I'm not sure if it's worth keeping it only for CMA, what are the CMA guys' opinions on that?

The way I understood it is that this patch is wrong, but it's still
alive in -mm. Should it still be there?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
