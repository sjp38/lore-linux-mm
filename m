Date: Fri, 14 Sep 2007 10:06:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] add page->mapping handling interface [1/35] interface
 definitions
Message-Id: <20070914100634.bee81fe6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46E99B48.6050106@student.ltu.se>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
	<20070910184239.e1f705c9.kamezawa.hiroyu@jp.fujitsu.com>
	<46E99B48.6050106@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Knutsson <ricknu-0@student.ltu.se>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007 22:19:20 +0200
Richard Knutsson <ricknu-0@student.ltu.se> wrote:
> > +static inline int page_is_pagecache(struct page *page)
> >   
> Why return it as an 'int' instead of 'bool'?
> > +{
> > +	if (!page->mapping || (page->mapping & PAGE_MAPPING_ANON))
> > +		return 0;
> > +	return 1;
> > +}

Ah, I missed bool type just because I have no experience to use 'bool' in
Linux kernel. ok, will try in the next version. thank you.

> >   
> Not easier with 'return page->mapping && (page->mapping & 
> PAGE_MAPPING_ANON) == 0;'?
> > +

yours seems better.


> 
> >  static inline int PageAnon(struct page *page)
> >   
> Change to bool? Then "you" can also remove the '!!' from:
> mm/memory.c:483:                rss[!!PageAnon(page)]++;

Hmm, will try unless it makes diff big.

> >  {
> > -	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
> > +	return (page->mapping & PAGE_MAPPING_ANON) != 0;
> > +}
> > +
> >   
> <snip>
> 
> If you don't mind bool(eans) (for some reason), I can/will check out the 
> rest.
> 

Thank you. I'll try 'bool' type. 

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
