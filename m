Date: Mon, 18 Jun 2007 15:33:21 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] mm: More __meminit annotations.
In-Reply-To: <20070618055842.GA17858@linux-sh.org>
References: <20070618143943.B108.Y-GOTO@jp.fujitsu.com> <20070618055842.GA17858@linux-sh.org>
Message-Id: <20070618151544.B10A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Mon, Jun 18, 2007 at 02:49:24PM +0900, Yasunori Goto wrote:
> > > -static inline unsigned long zone_absent_pages_in_node(int nid,
> > > +static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
> > >  						unsigned long zone_type,
> > >  						unsigned long *zholes_size)
> > >  {
> > 
> > I thought __meminit is not effective for these static functions,
> > because they are inlined function. So, it depends on caller's 
> > defenition. Is it wrong? 
> > 
> Ah, that's possible, I hadn't considered that. It seems to be a bit more
> obvious what the intention is if it's annotated, especially as this is
> the convention that's used by the rest of mm/page_alloc.c. A bit more
> consistent, if nothing more.

I'm not sure which is intended. I found some functions define both
__init and inline in kernel tree. And probably, some functions don't
do it. So, it seems there is no convention.

I'm Okay if you prefer both defined. :-)


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
