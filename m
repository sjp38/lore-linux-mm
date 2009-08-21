Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AE1A36B00A1
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:49:01 -0400 (EDT)
Date: Thu, 20 Aug 2009 17:19:28 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH] mm/vmscan: rename zone_nr_pages() to
 zone_lru_nr_pages()
In-Reply-To: <20090820160024.6e24dbb7.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.00.0908201707520.2172@mail.selltech.ca>
References: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca> <20090820160024.6e24dbb7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vincent Li <macli@brc.ubc.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Aug 2009, Andrew Morton wrote:

> On Thu, 20 Aug 2009 11:42:54 -0700
> Vincent Li <macli@brc.ubc.ca> wrote:
> 
> > Name zone_nr_pages can be mis-read as zone's (total) number pages, but it actually returns
> > zone's LRU list number pages.
> 
> Fair enough.
> 
> > -static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
> > +static unsigned long zone_lru_nr_pages(struct zone *zone, struct scan_control *sc,
> 
> Wouldn't zone_nr_lru_pages() be better?

I see name isolate_lru_page and the meaning of number of lru pages. your suggestion is better.
should I resend the patch with your suggestion? I ask because I saw you already put the patch in 
the mmotm tree before you send this email out.

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
