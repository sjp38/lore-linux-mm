Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC5346B00A6
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 09:21:18 -0400 (EDT)
Date: Tue, 22 Sep 2009 14:21:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3] Fix SLQB on memoryless configurations V3
Message-ID: <20090922132126.GC25965@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 01:54:11PM +0100, Mel Gorman wrote:
> Changelog since V2
>   o Turned out that allocating per-cpu areas for node ids on ppc64 just
>     wasn't stable. This series statically declares the per-node data. This
>     wastes memory but it appears to work.
> 
> Currently SLQB is not allowed to be configured on PPC and S390 machines as
> CPUs can belong to memoryless nodes. SLQB does not deal with this very well
> and crashes reliably.
> 

GACK. Sorry about the 1/4, 2/4, 3/4 problem. There are only three
patches in this set. I dropped the last patch which was related to the
SLQB corruption problem because it didn't appear to help and didn't fix
up the number. Sorry.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
