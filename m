Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1233A6B0126
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 17:35:26 -0400 (EDT)
Date: Wed, 22 Jul 2009 14:55:12 -0700 (PDT)
From: "Li, Ming Chun" <macli@brc.ubc.ca>
Subject: Re: [patch 5/4] mm: document is_page_cache_freeable()
In-Reply-To: <alpine.DEB.1.10.0907221500440.29748@gentwo.org>
Message-ID: <alpine.DEB.1.00.0907221447190.24706@mail.selltech.ca>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-4-git-send-email-hannes@cmpxchg.org> <alpine.DEB.1.10.0907221220350.3588@gentwo.org> <20090722175031.GA3484@cmpxchg.org> <20090722175417.GA7059@cmpxchg.org>
 <alpine.DEB.1.10.0907221500440.29748@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jul 2009, Christoph Lameter wrote:

> 
> >  static inline int is_page_cache_freeable(struct page *page)
> >  {
> > +	/*
> > +	 * A freeable page cache page is referenced only by the caller
> > +	 * that isolated the page, the page cache itself and
> 
> The page cache "itself"? This is the radix tree reference right?
> 

I think you are right. I had trouble understanding this function, So I 
looked into it and found out the call path:

 add_to_page_cache_locked 
   -> page_cache_get
    -> atomic_inc(&page->_count) 

Please correct me if I am wrong.

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
