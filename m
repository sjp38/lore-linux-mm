Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4FE9B6B005A
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 13:06:57 -0400 (EDT)
Date: Fri, 21 Aug 2009 10:29:43 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH] mm/vmscan: rename zone_nr_pages() to
 zone_lru_nr_pages()
In-Reply-To: <1250817819.4835.21.camel@pc-fernando>
Message-ID: <alpine.DEB.1.00.0908211025420.3187@mail.selltech.ca>
References: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca> <1250817819.4835.21.camel@pc-fernando>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Fernando Carrijo <fcarrijo@yahoo.com.br>
Cc: Vincent Li <macli@brc.ubc.ca>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Aug 2009, Fernando Carrijo wrote:

> On Thu, 2009-08-20 at 11:42 -0700, Vincent Li wrote:
> > Name zone_nr_pages can be mis-read as zone's (total) number pages, but it actually returns
> > zone's LRU list number pages.
> > 
> > I know reading the code would clear the name confusion, want to know if patch making sense.
> 
> In case this patch gets an ack, wouldn't it make sense to try to keep
> some consistency by renaming the function mem_cgroup_zone_nr_pages to
> mem_cgroup_zone_lru_nr_pages, since it also deals with an specific LRU?
> 
> Fernando Carrijo
> 

I thought about renaming mem_cgroup_zone_nr_pages too, but not sure if the 
patch make sense  when I submit, so I kept the changes as small as 
possible. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
