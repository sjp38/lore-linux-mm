Date: Fri, 20 Feb 2004 08:17:38 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040220161738.GF1269@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040216190927.GA2969@us.ibm.com> <200402201535.47848.phillips@arcor.de> <20040220140116.GD1269@us.ibm.com> <200402201800.12077.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200402201800.12077.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 20, 2004 at 06:00:32PM -0500, Daniel Phillips wrote:
> On Friday 20 February 2004 09:01, Paul E. McKenney wrote:
> > On Fri, Feb 20, 2004 at 03:37:26PM -0500, Daniel Phillips wrote:
> > > Actually, I erred there in that invalidate_mmap_range should not export
> > > the flag, because it never makes sense to pass in non-zero from a DFS.
> >
> > Doesn't vmtruncate() want to pass non-zero "all" in to
> > invalidate_mmap_range() in order to maintain compatibility with existing
> > Linux semantics?
> 
> That comes from inside.  The DFS's truncate interface should just be 
> vmtruncate.  If I missed something, please shout.

Agreed, the DFS's truncate interface should be vmtruncate().

Your earlier patch has a call to invalidate_mmap_range() within
vmtruncate(), which passes "1" to the last arg, so as to get
rid of all mappings to the truncated portion of the file.
So either invalidate_mmap_range() needs to keep the fourth arg
or needs to be a wrapper for an underlying function that
vmtruncate() can call, or some such.

The latter may be what you intended to do.

						Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
