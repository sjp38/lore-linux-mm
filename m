Date: Tue, 20 Nov 2007 13:33:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
Message-Id: <20071120133325.21fc819e.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0711201217430.26419@schroedinger.engr.sgi.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
	<20071109143426.23540.44459.sendpatchset@skynet.skynet.ie>
	<Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com>
	<20071120141953.GB32313@csn.ul.ie>
	<Pine.LNX.4.64.0711201217430.26419@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mel@csn.ul.ie, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 20 Nov 2007 12:18:10 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 20 Nov 2007, Mel Gorman wrote:
> 
> > Went back and revisited this. Allocating them at boot-time is below but
> > essentially it is a silly and it makes sense to just have two zonelists
> > where one of them is for __GFP_THISNODE. Implementation wise, this involves
> > dropping the last patch in the set and the overall result is still a reduction
> > in the number of zonelists.
> 
> Allright with me. Andrew could we get this patchset merged?

uhm, maybe.  It's getting toward the time when we should try to get -mm
vaguely compiling and booting on some machines, which means stopping
merging new stuff.  I left that too late in the 2.6.23 cycle.

otoh it'd be nice to get mainline fixed up a bit too :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
