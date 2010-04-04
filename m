Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B6BD6B01FC
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 12:03:35 -0400 (EDT)
Date: Sun, 4 Apr 2010 20:03:28 +0400
From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: why are some low-level MM routines being exported?
Message-ID: <20100404160328.GA30540@ioremap.net>
References: <alpine.LFD.2.00.1004041125350.5617@localhost> <1270396784.1814.92.camel@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1270396784.1814.92.camel@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org, Joern Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 2010 at 12:59:44AM +0900, Minchan Kim (minchan.kim@gmail.com) wrote:
> > perusing the code in mm/filemap.c and i'm curious as to why routines
> > like, for example, add_to_page_cache_lru() are being exported.  is it
> > really expected that loadable modules might access routines like that
> > directly?
> 
> It is added by 18bc0bbd162e3 for pohmelfs and now used by logfs, too. 
> I didn't noticed that at that time.
> With git log, any mm guys didn't add Signed-off-by or Reviewed-by.
> 
> I think it's not good for file system or module to use it directly. 
> It would make LRU management harder. 

How come?

> Is it really needed? Let's think again. 

Yes, it is really needed. It is not a some king of low-level mm magic to
export, but a useful interface to work with LRU lists instead of
copy-paste it into own machinery.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
