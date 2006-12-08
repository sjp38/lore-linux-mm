Message-ID: <45790212.8000608@goop.org>
Date: Thu, 07 Dec 2006 22:11:30 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
References: <20061204113051.4e90b249.akpm@osdl.org> <Pine.LNX.4.64.0612041133020.32337@schroedinger.engr.sgi.com> <20061204120611.4306024e.akpm@osdl.org> <Pine.LNX.4.64.0612041211390.32337@schroedinger.engr.sgi.com> <20061204131959.bdeeee41.akpm@osdl.org> <Pine.LNX.4.64.0612041337520.851@schroedinger.engr.sgi.com> <20061204142259.3cdda664.akpm@osdl.org> <Pine.LNX.4.64.0612050754560.11213@schroedinger.engr.sgi.com> <20061205112541.2a4b7414.akpm@osdl.org> <Pine.LNX.4.64.0612051159510.18687@schroedinger.engr.sgi.com> <20061205214721.GE20614@skynet.ie> <Pine.LNX.4.64.0612051521060.20570@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0612060903161.7238@skynet.skynet.ie> <Pine.LNX.4.64.0612060921230.26185@schroedinger.engr.sgi.com> <4578BE37.1010109@goop.org> <Pine.LNX.4.64.0612071817280.11503@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0612071817280.11503@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> The same can be done using the virtual->physical mappings that exist on 
> many platforms for the kernel address space (ia64 dynamically calculates 
> those, x86_64 uses a page table with 2M pages for mapping the kernel).

Yes, that's basically what Xen does - there's a nonlinear mapping from
kernel virtual to machine pages (and usermode pages are put through the
same transformation before being mapped).

>  The 
> problem is that the 1-1 mapping between physical and virtual addresses 
> will have to be (at least partially) sacrificed which may lead to 
> complications with DMA devices.
>   

Yes, any driver which expects contigious kernel pages to be physically
contigious will be sorely disappointed.  This isn't too hard to deal
with (since such drivers are often buggy anyway, making poor assumptions
about the relationship between physical addresses and bus addresses). 
An IOMMU could help as well.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
