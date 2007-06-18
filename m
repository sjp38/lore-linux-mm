Date: Mon, 18 Jun 2007 14:58:42 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] mm: More __meminit annotations.
Message-ID: <20070618055842.GA17858@linux-sh.org>
References: <20070618045229.GA31635@linux-sh.org> <20070618143943.B108.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070618143943.B108.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 18, 2007 at 02:49:24PM +0900, Yasunori Goto wrote:
> > -static inline unsigned long zone_absent_pages_in_node(int nid,
> > +static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
> >  						unsigned long zone_type,
> >  						unsigned long *zholes_size)
> >  {
> 
> I thought __meminit is not effective for these static functions,
> because they are inlined function. So, it depends on caller's 
> defenition. Is it wrong? 
> 
Ah, that's possible, I hadn't considered that. It seems to be a bit more
obvious what the intention is if it's annotated, especially as this is
the convention that's used by the rest of mm/page_alloc.c. A bit more
consistent, if nothing more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
