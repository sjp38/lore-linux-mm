Date: Fri, 10 Dec 2004 16:18:35 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and
 performance tests
Message-Id: <20041210161835.5b0b0828.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0412102346470.521-100000@localhost.localdomain>
References: <20041210141258.491f3d48.akpm@osdl.org>
	<Pine.LNX.4.44.0412102346470.521-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: clameter@sgi.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> On Fri, 10 Dec 2004, Andrew Morton wrote:
> > Hugh Dickins <hugh@veritas.com> wrote:
> > >
> > > > > (I do wonder why do_anonymous_page calls mark_page_accessed as well as
> > > > > lru_cache_add_active.  The other instances of lru_cache_add_active for
> > > > > an anonymous page don't mark_page_accessed i.e. SetPageReferenced too,
> > > > > why here?  But that's nothing new with your patch, and although you've
> > > > > reordered the calls, the final page state is the same as before.)
> > 
> > The point is a good one - I guess that code is a holdover from earlier
> > implementations.
> > 
> > This is equivalent, no?
> 
> Yes, it is equivalent to use SetPageReferenced(page) there instead.
> But why is do_anonymous_page adding anything to lru_cache_add_active,
> when its other callers leave it at that?  What's special about the
> do_anonymous_page case?

do_swap_page() is effectively doing the same as do_anonymous_page(). 
do_wp_page() and do_no_page() appear to be errant.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
