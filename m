Date: Mon, 7 Oct 2002 19:30:36 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Breakout struct page
Message-ID: <20021007193036.A25200@infradead.org>
References: <1165733025.1033777103@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1165733025.1033777103@[10.10.2.3]>; from mbligh@aracnet.com on Sat, Oct 05, 2002 at 12:18:23AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 05, 2002 at 12:18:23AM -0700, Martin J. Bligh wrote:
> This very boring patch breaks out struct page into it's own header
> file. This should allow you to do struct page arithmetic in other
> header files using static inlines instead of horribly complex macros 
> ... by just including <linux/struct_page.h>, which avoids dependency
> problems.
> 
> (inlined to read, attatched for lower probability of mangling)

I don't like a struct_page.h in addition to page-flags.h.  I had a patch
for early 2.5 that create <linux/page.h> with struct page and stuff that
depends only on it (Test/Set/etc macros).  IHMO that's a nicer split,
but people may flame me for this..

I'm inclinde to resubmit that one after feature freeze.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
