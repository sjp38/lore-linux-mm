Date: Tue, 18 Oct 2005 10:16:42 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 0/2] Page migration via Swap V2: Overview
Message-ID: <20051018121642.GA13963@logos.cnet>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, ak@suse.de, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Mon, Oct 17, 2005 at 05:49:32PM -0700, Christoph Lameter wrote:
> In a NUMA system it is often beneficial to be able to move the memory
> in use by a process to different nodes in order to enhance performance.
> Currently Linux simply does not support this facility.
> 
> Page migration is also useful for other purposes:
> 
> 1. Memory hotplug. Migrating processes off a memory node that is going
>    to be disconnected.
> 
> 2. Remapping of bad pages. These could be detected through soft ECC errors
>    and other mechanisms.
> 
> Work on page migration has been done in the context of the memory hotplug project
> (see https://lists.sourceforge.net/lists/listinfo/lhms-devel). Ray Bryant
> hs also posted a series of manual page migration patchsets. However, the patches
> are complex, and may have impacts on the VM in various places, there are unresolved
> issues regarding memory placement during direct migration and thus the functionality
> may not be available for some time.

Is there a description of the unresolved issues you mention somewhere?

Having a duplicate implementation is somewhat disappointing - why not fix the problems
with real page migration?

> This patchset was done in awareness of the work done there and realizes page
> migration via swap. Pages are not directly moved to their target
> location but simply swapped out. If the application touches the page later then
> a new page is allocated in the desired location.
> 
> The advantage of page based swapping is that the necessary changes to the kernel
> are minimal. With a fully functional but minimal page migration capability we
> will be able to enhance low level code and higher level APIs at the same time.

> This will hopefully decrease the time needed to get the code for direct page
> migration working and into the kernel trees.

Why would that be the case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
