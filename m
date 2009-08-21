Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7F7D76B005A
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 13:32:06 -0400 (EDT)
Subject: Re: [PATCH] mm/vmscan: rename zone_nr_pages() to
 zone_lru_nr_pages()
From: Fernando Carrijo <fcarrijo@yahoo.com.br>
In-Reply-To: <20090820172239.061c0de0.akpm@linux-foundation.org>
References: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca>
	 <20090820160024.6e24dbb7.akpm@linux-foundation.org>
	 <alpine.DEB.1.00.0908201707520.2172@mail.selltech.ca>
	 <20090820172239.061c0de0.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 21 Aug 2009 14:32:02 -0300
Message-Id: <1250875922.4830.21.camel@pc-fernando>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vincent Li <macli@brc.ubc.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I sent this very message yesterday and somehow it got lost. Today I'm
resending it with the hope breaks through whatever spam filter it may
find in its way...

On Thu, 2009-08-20 at 17:22 -0700, Andrew Morton wrote:
> On Thu, 20 Aug 2009 17:19:28 -0700 (PDT)
> Vincent Li <macli@brc.ubc.ca> wrote:
> 
> > On Thu, 20 Aug 2009, Andrew Morton wrote:
> > 
> > > On Thu, 20 Aug 2009 11:42:54 -0700
> > > Vincent Li <macli@brc.ubc.ca> wrote:
> > > 
> > > > Name zone_nr_pages can be mis-read as zone's (total) number pages, but it actually returns
> > > > zone's LRU list number pages.
> > > 
> > > Fair enough.
> > > 
> > > > -static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
> > > > +static unsigned long zone_lru_nr_pages(struct zone *zone, struct scan_control *sc,
> > > 
> > > Wouldn't zone_nr_lru_pages() be better?
> > 
> > I see name isolate_lru_page and the meaning of number of lru pages. your suggestion is better.
> > should I resend the patch with your suggestion? I ask because I saw you already put the patch in 
> > the mmotm tree before you send this email out.
> > 
> 
> I edited the diff ;)

Wouldn't it make sense to try to keep some consistency by renaming the
function mem_cgroup_zone_nr_pages to mem_cgroup_zone_nr_lru_pages, for
it also deals with a specific LRU?

Fernando Carrijo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
