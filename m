Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id DE2A86B0071
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 05:58:08 -0400 (EDT)
Date: Wed, 8 Aug 2012 10:58:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/6] mm: kswapd: Continue reclaiming for
 reclaim/compaction if the minimum number of pages have not been reclaimed
Message-ID: <20120808095803.GL29814@suse.de>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-4-git-send-email-mgorman@suse.de>
 <20120808020749.GC4247@bbox>
 <20120808090757.GK29814@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120808090757.GK29814@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 08, 2012 at 10:07:57AM +0100, Mel Gorman wrote:
> > <SNIP>
> 
> It was intentional at the time but asking me about it made me reconsider,
> thanks. In too many cases, this is a no-op and any apparent increase of
> kswapd activity is likely a co-incidence. This is untested but is what I
> intended.
> 
> ---8<---
> mm: kswapd: Continue reclaiming for reclaim/compaction if the minimum number of pages have not been reclaimed
> 

And considering this further again, it would partially regress fe2c2a10
and be too aggressive. I'm dropping this patch completely for now and will
revisit it in the future.

Thanks Minchan.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
