Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 40DB96B0055
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:24:26 -0400 (EDT)
Date: Tue, 21 Apr 2009 16:24:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 24/25] Re-sort GFP flags and fix whitespace alignment
	for easier reading.
Message-ID: <20090421152442.GB29083@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-25-git-send-email-mel@csn.ul.ie> <1240301043.771.56.camel@penberg-laptop> <20090421085229.GH12713@csn.ul.ie> <alpine.DEB.1.10.0904211107250.19969@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904211107250.19969@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 11:08:46AM -0400, Christoph Lameter wrote:
> On Tue, 21 Apr 2009, Mel Gorman wrote:
> 
> > Hmm, doh. This resorted when another patch existed that no longer exists
> > due to difficulties. This patch only fixes whitespace now but I didn't fix
> > the changelog.  I can either move it to the next set altogether where it
> > does resort things or drop it on the grounds whitespace patches just muck
> > with changelogs. I'm leaning towards the latter.
> 
> Where were we with that other patch? I vaguely recalling reworking the
> other patch (gfp_zone I believe) to be calculated at compile time. Did I
> drop this?
> 

No, you didn't. I have a version still that's promising but doesn't currently
work nor has been tested to show it really helps. It's on the long finger
till pass 2 where it'll be high on the list to sort out.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
