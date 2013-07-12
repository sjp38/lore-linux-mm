Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 4531E6B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 19:24:08 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id um15so9512462pbc.24
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 16:24:07 -0700 (PDT)
Message-ID: <51E0900E.9080504@gmail.com>
Date: Sat, 13 Jul 2013 07:23:58 +0800
From: Hush Bensen <hush.bensen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] mm: compaction: add compaction to zone_reclaim_mode
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-8-git-send-email-aarcange@redhat.com> <20130606100503.GH1936@suse.de> <20130711160216.GA30320@redhat.com> <51DFF5FD.8040007@gmail.com> <20130712160149.GB4524@redhat.com>
In-Reply-To: <20130712160149.GB4524@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

Hi Andrea,
ao? 2013/7/13 0:01, Andrea Arcangeli a??e??:
> Hi,
>
> On Fri, Jul 12, 2013 at 06:26:37AM -0600, Hush Bensen wrote:
>>> This isn't VM reclaim, we're not globally low on memory and we can't
>>> wake kswapd until we expired all memory from all zones or we risk to
>>> screw the lru rotation even further (by having kswapd and the thread
>> What's the meaning of lru rotation?
> I mean the per-zone LRU walks to shrink the memory (they rotate pages
> through the LRU). To provide for better global working set information
> in the LRUs, we should walk all the zone LRUs in a fair
> way.
>
> zone_reclaim_mode however makes it non fair by always shrinking from
> the first NUMA local zone even if the other zones could be shrunk
> too.
>
> When zone_reclaim_mode is disabled instead (default for most hardware
> out there), we wait all candidate zones to be at the low wmark before
> starting the shrinking from any zone (and then we shrink all zones,
> not just one). So when zone_reclaim_mode is disabled, we don't insist
> aging a single zone indefinitely, while leaving the others un-aged.

Do you mean your patch done this fair? There is target zone shrink as 
you mentiond in the vanilla kernel, however, your patch also done target 
compaction/reclaim, is this fair?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
