Message-ID: <20060206052627.8205.qmail@web33004.mail.mud.yahoo.com>
Date: Sun, 5 Feb 2006 21:26:27 -0800 (PST)
From: Shantanu Goel <sgoel01@yahoo.com>
Subject: Re: [VM PATCH] rotate_reclaimable_page fails frequently
In-Reply-To: <20060205205056.01a025fa.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Rik van Riel <riel@surriel.com>
Cc: sgoel01@yahoo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Andrew Morton <akpm@osdl.org> wrote:

> Rik van Riel <riel@surriel.com> wrote:
> >  The question is, why is the page not yet back on
> the
> >  LRU by the time the data write completes ?
> 
> Could be they're ext3 pages which were written out
> by kjournald.  Such
> pages are marked dirty but have clean buffers. 
> ext3_writepage() will
> discover that the page is actually clean and will
> mark it thus without
> performing any I/O.
> 

I had conjectured that something like this might be
happening without knowing the details of how ext3
implements writepage.  The filesystem tested on here
is  ext3.

> Shantanu, I suggest you add some instrumentation
> there too, see if it's
> working.  (That'll be non-trivial.  Just because we
> hit PAGE_CLEAN: here
> doesn't necessarily mean that the page will be
> reclaimed).

I'll do so and report back the results.

Shantanu


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
