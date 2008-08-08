Date: Fri, 8 Aug 2008 09:51:36 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: question about do_anonymous_page()
In-Reply-To: <38b2ab8a0808080123t5083dc17qa250bd02c753f80d@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0808080938001.15941@blonde.site>
References: <38b2ab8a0808080101v795327f0n9da5adb33a3c1a9@mail.gmail.com>
 <38b2ab8a0808080123t5083dc17qa250bd02c753f80d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Francis Moreau <francis.moro@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Aug 2008, Francis Moreau wrote:
> On Fri, Aug 8, 2008 at 10:01 AM, Francis Moreau <francis.moro@gmail.com> wrote:
> >
> > I'm wondering why do_anonymous_page() calls lru_cache_add_active(page)
> > where page does not belong to the page cache ?
> >
> > Is it simply because lru_add_active() doesn't exist ?

Yes.

It just happens that whoever (Rik?) originally named that function was
primarily thinking of the page cache at the time; or perhaps wasn't
thinking of the file page cache at all, just regarding all the pages
we put on that list as cached in some sense.

You're right that it's a little anomalous, but nothing to worry about.
I get more bothered by page_cache_get(), which is and always(?) has
been the same thing as get_page(): sometimes we use one, sometimes
the other, and often we use page_cache_get() on anonymous pages.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
