Date: Mon, 10 Mar 2008 12:55:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: what to patch
Message-Id: <20080310125559.796bdaaf.akpm@linux-foundation.org>
In-Reply-To: <20080310122010.a2170c9c.randy.dunlap@oracle.com>
References: <alpine.DEB.1.00.0803071720460.4611@chino.kir.corp.google.com>
	<20080310120902.5f25b9f9.akpm@linux-foundation.org>
	<20080310122010.a2170c9c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Mar 2008 12:20:10 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Mon, 10 Mar 2008 12:09:02 -0700 Andrew Morton wrote:
> 
> > I get a significant-looking reject from this.  Can you please redo and
> > resend?
> > 
> > 
> > I put my current rollup (against -rc5) at
> > http://userweb.kernel.org/~akpm/dr.gz and the broken-out tree is, as always
> > at http://userweb.kernel.org/~akpm/mmotm/
> > 
> > It would be better for you to get set up for using mmotm - it is my usual
> > way of publishing the -mm queue between releases.
> 
> Speaking of what to patch, I'm looking at making a big set of
> kernel-docbook changes/fixes/additions to the mm/ subdir.
> Should I make patches to mainline or -mm (or mmotm) or what?

mmotm would be best please.

> mm/ seems to have a *lot* of patches. ;)

Actually the number of memory-management patches in -mm is much less this
time than it usually is.  Perhaps we finished it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
