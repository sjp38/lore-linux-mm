Message-ID: <4636F626.7030609@shadowen.org>
Date: Tue, 01 May 2007 09:11:18 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- pfn_valid_within
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>  add-pfn_valid_within-helper-for-sub-max_order-hole-detection.patch
>  anti-fragmentation-switch-over-to-pfn_valid_within.patch
>  lumpy-move-to-using-pfn_valid_within.patch
> 
> More Mel things, and linkage between Mel-things and lumpy reclaim.  It's here
> where the patch ordering gets into a mess and things won't improve if
> moveable-zones and lumpy-reclaim get deferred.  Such a deferral would limit my
> ability to queue more MM changes for 2.6.23.

The first of these is really a cleanup and should slide into the stack
before Mobility and Lumpy.  The other two should then join their
respective stacks anti-fragmentation-... to Mobility and lumpy-... to
Lumpy.  I would not expect them to increase linkage that way.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
