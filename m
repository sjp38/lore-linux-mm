Date: Fri, 10 Dec 2004 23:52:30 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
    tests
In-Reply-To: <20041210141258.491f3d48.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0412102346470.521-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2004, Andrew Morton wrote:
> Hugh Dickins <hugh@veritas.com> wrote:
> >
> > > > (I do wonder why do_anonymous_page calls mark_page_accessed as well as
> > > > lru_cache_add_active.  The other instances of lru_cache_add_active for
> > > > an anonymous page don't mark_page_accessed i.e. SetPageReferenced too,
> > > > why here?  But that's nothing new with your patch, and although you've
> > > > reordered the calls, the final page state is the same as before.)
> 
> The point is a good one - I guess that code is a holdover from earlier
> implementations.
> 
> This is equivalent, no?

Yes, it is equivalent to use SetPageReferenced(page) there instead.
But why is do_anonymous_page adding anything to lru_cache_add_active,
when its other callers leave it at that?  What's special about the
do_anonymous_page case?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
