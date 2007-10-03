Date: Wed, 3 Oct 2007 03:58:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
Message-Id: <20071003035853.c5a777e2.akpm@linux-foundation.org>
In-Reply-To: <200710030345.10026.nickpiggin@yahoo.com.au>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
	<200710030345.10026.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Torvalds, Linus" <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Oct 2007 03:45:09 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > mm-use-pagevec-to-rotate-reclaimable-page.patch
> > mm-use-pagevec-to-rotate-reclaimable-page-fix.patch
> > mm-use-pagevec-to-rotate-reclaimable-page-fix-2.patch
> > mm-use-pagevec-to-rotate-reclaimable-page-fix-function-declaration.patch
> > mm-use-pagevec-to-rotate-reclaimable-page-fix-bug-at-include-linux-mmh220.p
> >atch
> > mm-use-pagevec-to-rotate-reclaimable-page-kill-redundancy-in-rotate_reclaim
> >able_page.patch
> > mm-use-pagevec-to-rotate-reclaimable-page-move_tail_pages-into-lru_add_drai
> >n.patch
> >
> >   I guess I'll merge this.  Would be nice to have wider perfromance testing
> >   but I guess it'll be easy enough to undo.
> 
> Care to give it one more round through -mm? Is it easy enough to
> keep?

Yup.  Nobody has done much with that code in ages.

> I haven't had a chance to review it, which I'd like to do at some
> point (and I don't think it would hurt to have a bit more testing).

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
