Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A1CAE6B021B
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 08:47:43 -0400 (EDT)
Date: Mon, 5 Apr 2010 16:47:36 +0400
From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: why are some low-level MM routines being exported?
Message-ID: <20100405124736.GA11214@ioremap.net>
References: <alpine.LFD.2.00.1004041125350.5617@localhost> <1270396784.1814.92.camel@barrios-desktop> <20100404160328.GA30540@ioremap.net> <1270398112.1814.114.camel@barrios-desktop> <20100404181550.GA2350@ioremap.net> <t2z28c262361004041736w61b066efr29557741424e158e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <t2z28c262361004041736w61b066efr29557741424e158e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org, Joern Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 2010 at 09:36:00AM +0900, Minchan Kim (minchan.kim@gmail.com) wrote:
> > All filesystems already call it through find_or_create_page() or
> > grab_page() invoked via read path. In some cases fs has more than
> > one page grabbed via its internal path where data to be read is
> > already placed, so it may want just to add those pages into mm lru.
> 
> I understood why it does need that in pohmelfs.
> AFAIU, other file system using general functions(ex, mpage_readpages or
> read_cache_pages) don't need direct LRU handling since it's hided.
> But pohmelfs doesn't use general functions.
> 
> Isn't pagevec_lru_add_file enough like other file system(ex, nfs, cifs)?

This will force to reinvent add_to_page_cache_lru() by doing private
function which will call add_to_page_cache() and pagevec_lru_add_file(),
which is effectively what is being done for file backed pages in
add_to_page_cache_lru().

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
