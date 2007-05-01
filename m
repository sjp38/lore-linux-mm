Date: Tue, 1 May 2007 01:19:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans -- pfn_valid_within
Message-Id: <20070501011935.a2b90633.akpm@linux-foundation.org>
In-Reply-To: <4636F626.7030609@shadowen.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<4636F626.7030609@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 01 May 2007 09:11:18 +0100 Andy Whitcroft <apw@shadowen.org> wrote:

> Andrew Morton wrote:
> 
> >  add-pfn_valid_within-helper-for-sub-max_order-hole-detection.patch
> >  anti-fragmentation-switch-over-to-pfn_valid_within.patch
> >  lumpy-move-to-using-pfn_valid_within.patch
> > 
> > More Mel things, and linkage between Mel-things and lumpy reclaim.  It's here
> > where the patch ordering gets into a mess and things won't improve if
> > moveable-zones and lumpy-reclaim get deferred.  Such a deferral would limit my
> > ability to queue more MM changes for 2.6.23.
> 
> The first of these is really a cleanup and should slide into the stack
> before Mobility and Lumpy.  The other two should then join their
> respective stacks anti-fragmentation-... to Mobility and lumpy-... to
> Lumpy.  I would not expect them to increase linkage that way.
> 

yup, that improved things a bit, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
