Date: Tue, 27 Feb 2001 14:42:33 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.5 page cache improvement idea
Message-ID: <20010227144233.A12205@athlon.random>
References: <Pine.LNX.4.30.0102262142500.9589-100000@today.toronto.redhat.com> <200102270326.f1R3QII16835@eng1.sequent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200102270326.f1R3QII16835@eng1.sequent.com>; from gerrit@us.ibm.com on Mon, Feb 26, 2001 at 07:26:18PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gerrit@us.ibm.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Chuck Lever <Charles.Lever@netapp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 26, 2001 at 07:26:18PM -0800, Gerrit Huizenga wrote:
> If you are considering NUMA architectures as a case of frequently
> accesses pages, e.g. glibc or text pages of commonly used executables,
> it is probably better to do page replication per node on demand than
> to worry about optimizing the page lookups for limited bus traffic.
> 
> Most NUMA machines are relatively rich in physical memory, and cross
> node traffic is relatively expensive.  As a result, wasting a small
> number of physical pages on duplicate read-only pages cuts down node
> to node traffic in most cases.  Many NUMA systems have a cache for
> remote memory (some cache only remote pages, some cache local and remote
> pages in the same cache - icky but cheaper).  As that cache cycles,
> it is cheaper to replace read-only text pages from the local node
> rather than the remote.  So, for things like kernel text (e.g. one of
> the SGI patches) and for glibc's text, as well as the text of other
> common shared libraries, it winds up being a significant win to replicate
> those text pages (on demand!) in local memory.

Agreed.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
