Date: Thu, 29 May 2003 17:33:04 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Avoid vmtruncate/mmap-page-fault race
In-Reply-To: <20030529151424.GA1397@us.ibm.com>
Message-ID: <Pine.LNX.4.44.0305291723310.1800-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: phillips@arcor.de, akpm@digeo.com, hch@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 May 2003, Paul E. McKenney wrote:
> On Fri, May 23, 2003 at 11:42:02AM -0700, Paul E. McKenney wrote:
> > 
> > Exactly -- allows a ->nopage() to drop some lock to avoid races
> > between pagefault and either vmtruncate() or invalidate_mmap_range().
> > This race (from the cross-host mmap viewpoint) is described in:
> > 
> >     http://marc.theaimsgroup.com/?l=linux-kernel&m=105286345316249&w=2
> 
> Rediffed for 2.5.70-mm1.

Me?  I much preferred your original, much sparer, nopagedone patch
(labelled "uglyh as hell" by hch).  I dislike passing lots of args
down a level so they can be passed up again to the library function.

In particular, I feel queasy (fear loss of control) about passing a
pmd_t* down to a filesystem, which I'd prefer to have no access to
such.  But I may be in a minority, and the decision won't be mine.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
