Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 056CF6B005A
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:18:15 -0400 (EDT)
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [140.211.169.55])
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id n7LFIIm0001931
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 08:18:19 -0700
Date: Thu, 20 Aug 2009 17:22:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmscan: rename zone_nr_pages() to
 zone_lru_nr_pages()
Message-Id: <20090820172239.061c0de0.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.1.00.0908201707520.2172@mail.selltech.ca>
References: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca>
	<20090820160024.6e24dbb7.akpm@linux-foundation.org>
	<alpine.DEB.1.00.0908201707520.2172@mail.selltech.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Aug 2009 17:19:28 -0700 (PDT)
Vincent Li <macli@brc.ubc.ca> wrote:

> On Thu, 20 Aug 2009, Andrew Morton wrote:
> 
> > On Thu, 20 Aug 2009 11:42:54 -0700
> > Vincent Li <macli@brc.ubc.ca> wrote:
> > 
> > > Name zone_nr_pages can be mis-read as zone's (total) number pages, but it actually returns
> > > zone's LRU list number pages.
> > 
> > Fair enough.
> > 
> > > -static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
> > > +static unsigned long zone_lru_nr_pages(struct zone *zone, struct scan_control *sc,
> > 
> > Wouldn't zone_nr_lru_pages() be better?
> 
> I see name isolate_lru_page and the meaning of number of lru pages. your suggestion is better.
> should I resend the patch with your suggestion? I ask because I saw you already put the patch in 
> the mmotm tree before you send this email out.
> 

I edited the diff ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
