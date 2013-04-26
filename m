Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id DFBE36B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 20:21:08 -0400 (EDT)
Date: Fri, 26 Apr 2013 09:21:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm, highmem: remove useless virtual variable in
 page_address_map
Message-ID: <20130426002107.GA3075@lge.com>
References: <1366619188-28087-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20130425150057.c25220a8f03e068f5bea5d58@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130425150057.c25220a8f03e068f5bea5d58@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

On Thu, Apr 25, 2013 at 03:00:57PM -0700, Andrew Morton wrote:
> On Mon, 22 Apr 2013 17:26:28 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > We can get virtual address without virtual field.
> > So remove it.
> > 
> > ...
> >
> > --- a/mm/highmem.c
> > +++ b/mm/highmem.c
> > @@ -320,7 +320,6 @@ EXPORT_SYMBOL(kunmap_high);
> >   */
> >  struct page_address_map {
> >  	struct page *page;
> > -	void *virtual;
> >  	struct list_head list;
> >  };
> >  
> > @@ -362,7 +361,10 @@ void *page_address(const struct page *page)
> >  
> >  		list_for_each_entry(pam, &pas->lh, list) {
> >  			if (pam->page == page) {
> > -				ret = pam->virtual;
> > +				int nr;
> > +
> > +				nr = pam - page_address_map;
> 
> Doesn't compile.  Presumably you meant page_address_maps.
> 
> I'll drop this - please resend if/when it has been runtime tested.

Sorry for that.
I'll resend when it has been runtime tested.

Thanks.

> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
