Date: Sat, 31 May 2003 16:51:23 -0700
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [RFC][PATCH] Convert do_no_page() to a hook to avoid DFS race
Message-ID: <20030531235123.GC1408@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20030530164150.A26766@us.ibm.com> <20030530180027.75680efd.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030530180027.75680efd.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, May 30, 2003 at 06:00:27PM -0700, Andrew Morton wrote:
> "Paul E. McKenney" <paulmck@us.ibm.com> wrote:
> > There
> > is still an inlined do_no_page() wrapper due to the fact that
> > do_anonymous_page() requires that the mm->page_table_lock be
> > held on entry, while the ->nopage callouts require that this
> > lock be dropped.
> 
> I sugest you change the ->nopage definition so that page_table_lock is held
> on entry to ->nopage, and ->nopage must drop it at some point.  This gives
> the nopage implementations some more flexibility and may perhaps eliminate
> that special case?

Will do!

> > This patch is untested.
> 
> I don't think there's a lot of point in making changes until the code which
> requires those changes is accepted into the tree.  Otherwise it may be
> pointless churn, and there's nothing in-tree to exercise the new features.

A GPLed use of these DFS features is expected Real Soon Now...

						Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
