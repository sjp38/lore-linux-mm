Date: Fri, 23 May 2003 17:21:53 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Avoid vmtruncate/mmap-page-fault race
In-Reply-To: <20030523073500.A1549@us.ibm.com>
Message-ID: <Pine.LNX.4.44.0305231713230.1602-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, phillips@arcor.de, hch@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 May 2003, Paul E. McKenney wrote:
> On Tue, May 20, 2003 at 01:11:57AM -0700, Andrew Morton wrote:
> > 
> > However there is not a lot of commonality between the various nopage()s and
> > there may not be a lot to be gained from all this.  There is subtle code in
> > there and it is performance-critical.  I'd be inclined to try to minimise
> > overall code churn in this work.
> 
> Good point!  Here is a patch to do this.  A "few" caveats:

Sorry, I miss the point of this patch entirely.  At the moment it just
looks like an unattractive rearrangement - the code churn akpm advised
against - with no bearing on that vmtruncate race.  Please correct me.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
