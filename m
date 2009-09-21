Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 17E286B008C
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 13:46:51 -0400 (EDT)
Date: Mon, 21 Sep 2009 18:46:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
Message-ID: <20090921174656.GS12726@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 05:10:23PM +0100, Mel Gorman wrote:
> Currently SLQB is not allowed to be configured on PPC and S390 machines as
> CPUs can belong to memoryless nodes. SLQB does not deal with this very well
> and crashes reliably.
> 
> These patches fix the problem on PPC64 and it appears to be fairly stable.
> At least, basic actions that were previously silently halting the machine
> complete successfully.

I spoke too soon. Stress tests result in application failure, nothing to
dmesg even with the patches applied so it looks like patch 2 is still the
wrong way to fix the OOM-kill storm.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
