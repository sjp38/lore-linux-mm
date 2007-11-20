Date: Tue, 20 Nov 2007 21:26:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
Message-ID: <20071120212647.GA18867@csn.ul.ie>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie> <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com> <20071120141953.GB32313@csn.ul.ie> <Pine.LNX.4.64.0711201217430.26419@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711201217430.26419@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On (20/11/07 12:18), Christoph Lameter didst pronounce:
> On Tue, 20 Nov 2007, Mel Gorman wrote:
> 
> > Went back and revisited this. Allocating them at boot-time is below but
> > essentially it is a silly and it makes sense to just have two zonelists
> > where one of them is for __GFP_THISNODE. Implementation wise, this involves
> > dropping the last patch in the set and the overall result is still a reduction
> > in the number of zonelists.
> 
> Allright with me. Andrew could we get this patchset merged?
> 

They will not merge cleanly with a recent tree. I expect to be ready to
post a new set when regression tests complete later this evening.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
