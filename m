Date: Fri, 23 May 2003 18:47:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Avoid vmtruncate/mmap-page-fault race
In-Reply-To: <200305231910.58743.phillips@arcor.de>
Message-ID: <Pine.LNX.4.44.0305231840300.1713-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, Andrew Morton <akpm@digeo.com>, hch@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 May 2003, Daniel Phillips wrote:
> On Friday 23 May 2003 18:21, Hugh Dickins wrote:
> > Sorry, I miss the point of this patch entirely.  At the moment it just
> > looks like an unattractive rearrangement - the code churn akpm advised
> > against - with no bearing on that vmtruncate race.  Please correct me.
> 
> This is all about supporting cross-host mmap (nice trick, huh?).  Yes, 
> somebody should post a detailed rfc on that subject.

Ah, thanks - translated into terms that I can understand, so that
some ->nopage() not yet in the tree could do something after the
install_new_page() returns.  Hmm.  Can we be sure it's appropriate
for install_new_page to drop mm->page_table_lock before it returns?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
