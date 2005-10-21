Received: by zproxy.gmail.com with SMTP id k1so341032nzf
        for <linux-mm@kvack.org>; Thu, 20 Oct 2005 23:27:43 -0700 (PDT)
Message-ID: <aec7e5c30510202327l7ce5a89ax7620241ba57a4efa@mail.gmail.com>
Date: Fri, 21 Oct 2005 15:27:43 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 1/4] Swap migration V3: LRU operations
In-Reply-To: <1129874762.26533.5.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
	 <20051020225940.19761.93396.sendpatchset@schroedinger.engr.sgi.com>
	 <1129874762.26533.5.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, Mike Kravetz <kravetz@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On 10/21/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Thu, 2005-10-20 at 15:59 -0700, Christoph Lameter wrote:
>
> > +/*
> > + * Isolate one page from the LRU lists.
> > + *
> > + * - zone->lru_lock must be held
> > + *
> > + * Result:
> > + *  0 = page not on LRU list
> > + *  1 = page removed from LRU list
> > + * -1 = page is being freed elsewhere.
> > + */
>
> Can these return values please get some real names?  I just hate when
> things have more than just fail and success as return codes.
>
> It makes much more sense to have something like:
>
>         if (ret == ISOLATION_IMPOSSIBLE) {

Absolutely. But this involves figuring out nice names that everyone
likes and that does not pollute the name space too much. Any
suggestions?

> How about
>
> +static inline int
> > +__isolate_lru_page(struct zone *zone, struct page *page)
> > +{
>         int ret = 0;
>
>         if (!TestClearPageLRU(page))
>                 return ret;
>
> Then, the rest of the thing doesn't need to be indented.

Good idea.

> > +static inline void
> > +__putback_lru_page(struct zone *zone, struct page *page)
> > +{
>
> __put_back_lru_page?
>
> BTW, it would probably be nice to say where these patches came from
> before Magnus. :)

Uh? Yesterday I broke out code from isolate_lru_pages() and
shrink_cache() and emailed Christoph privately. Do you have similar
code in your tree?

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
