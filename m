Date: Mon, 9 Jul 2007 12:04:57 +0100
Subject: Re: zone movable patches comments
Message-ID: <20070709110457.GB9305@skynet.ie>
References: <4691E8D1.4030507@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4691E8D1.4030507@yahoo.com.au>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On (09/07/07 17:50), Nick Piggin didst pronounce:
> Hi Mel,
> 
> Just had a bit of a look at the zone movable stuff in -mm...

Great.

> Firstly,
> would it be possible to list all the dependant patches in that set, or
> is it just those few that are contiguous in Andrew's series file?
> 

add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch
and the few that are contiguous. I'm beginning to test with the
following series file

add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch
create-the-zone_movable-zone.patch
create-the-zone_movable-zone-fix.patch
create-the-zone_movable-zone-fix-2.patch
allow-huge-page-allocations-to-use-gfp_high_movable.patch
allow-huge-page-allocations-to-use-gfp_high_movable-fix.patch
allow-huge-page-allocations-to-use-gfp_high_movable-fix-2.patch
allow-huge-page-allocations-to-use-gfp_high_movable-fix-3.patch
handle-kernelcore=-generic.patch
handle-kernelcore=-generic-fix.patch

There was a minor reject in
add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch
but otherwise applied smoothly.

> A few comments -- can it be made configurable? I guess there is not
> much overhead if the zone is not populated, but there has been a fair
> bit of work towards taking out unneeded zones.
> 

It could be made configurable as zone_type already has configurable
zones. However, as it is that would always be set on distro kernels for
CONFIG_HUGETLB_PAGE, is there any point? It might make sense for embedded
systems but I've received pushback from Andrew before for trying to introduce
config options that affect the allocator before.

> Also, I don't really like the name kernelcore= to specify mem-sizeof
> movable zone. Could it be renamed and stated in the positive, like
> movable_mem= or reserve_movable_mem=?

It could but it was named this way for a reason. It was more important that
the administrator get the amount of memory for non-movable allocations
correct than movable allocations. If the size of ZONE_MOVABLE is wrong,
the hugepage pool may not be able to grow as large as desired. If the size
of memory usable of non-movable allocations is wrong, it's worse.

> And can that option be written
> up in Documentation?
> 

Documentation/kernel-parameters.txt

> What is the status of these patches? Are they working and pretty well
> ready to be merged for 2.6.23?
> 

I have not encountered problems with them in a long time. I'm re-testing now
using 2.6.22 as a baseline but I believe they are ready for merging to 2.6.23.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
