Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C45E46B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 11:39:24 -0500 (EST)
Date: Thu, 18 Nov 2010 16:39:08 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 66] Transparent Hugepage Support #32
Message-ID: <20101118163908.GI8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <patchbomb.1288798055@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:27:35PM +0100, Andrea Arcangeli wrote:
> Some of some relevant user of the project:
> 
> KVM Virtualization
> GCC (kernel build included, requires a few liner patch to enable)
> JVM
> VMware Workstation
> HPC
> 
> It would be great if it could go in -mm.
> 

FWIW, I saw nothing of major concern while reading through the series other
than the delete-lumpy-reclaim portion. I've posted a series that should
address both the lumpy reclaim concerns while also improving the performance
of compaction in general.

For the rest of the series, the vast majority of my comments were nits as
my questions were covered (and addressed) in previous revisions. I'll try
and set time aside to convert some of the libhugetlbfs-orientated to run
against these patches but I'm not anticipating any problems and it'd be
nice to see merged at some point.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
