Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A47B66B005D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 10:52:40 -0400 (EDT)
Date: Tue, 7 Aug 2012 15:52:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/6] mm: have order > 0 compaction start near a pageblock
 with free pages
Message-ID: <20120807145233.GG29814@suse.de>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-7-git-send-email-mgorman@suse.de>
 <50212A05.2070503@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50212A05.2070503@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 07, 2012 at 10:45:25AM -0400, Rik van Riel wrote:
> On 08/07/2012 08:31 AM, Mel Gorman wrote:
> >commit [7db8889a: mm: have order>  0 compaction start off where it left]
> >introduced a caching mechanism to reduce the amount work the free page
> >scanner does in compaction. However, it has a problem. Consider two process
> >simultaneously scanning free pages
> >
> >				    			C
> >Process A		M     S     			F
> >		|---------------------------------------|
> >Process B		M 	FS
> 
> Argh. Good spotting.
> 
> >This is not optimal and it can still race but the compact_cached_free_pfn
> >will be pointing to or very near a pageblock with free pages.
> 
> Agreed on the "not optimal", but I also cannot think of a better
> idea right now. Getting this fixed for 3.6 is important, we can
> think of future optimizations in San Diego.
> 

Sounds like a plan.

> >Signed-off-by: Mel Gorman<mgorman@suse.de>
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> 

Thanks very much.

Jim, what are the chances of getting this series tested with your large
data workload? As it's on top of 3.5, it should be less scary than
testing 3.6-rc1 but if you are comfortable testing 3.6-rc1 then please
test with just this patch on top.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
