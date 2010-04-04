Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D07EA6B01FE
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 12:17:26 -0400 (EDT)
Received: by gxk10 with SMTP id 10so2580349gxk.10
        for <linux-mm@kvack.org>; Sun, 04 Apr 2010 09:17:24 -0700 (PDT)
Subject: Re: why are some low-level MM routines being exported?
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100404160328.GA30540@ioremap.net>
References: <alpine.LFD.2.00.1004041125350.5617@localhost>
	 <1270396784.1814.92.camel@barrios-desktop>
	 <20100404160328.GA30540@ioremap.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 05 Apr 2010 01:17:18 +0900
Message-ID: <1270397838.1814.110.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Cc: "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org, Joern Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-04-04 at 20:03 +0400, Evgeniy Polyakov wrote:
> On Mon, Apr 05, 2010 at 12:59:44AM +0900, Minchan Kim (minchan.kim@gmail.com) wrote:
> > > perusing the code in mm/filemap.c and i'm curious as to why routines
> > > like, for example, add_to_page_cache_lru() are being exported.  is it
> > > really expected that loadable modules might access routines like that
> > > directly?
> > 
> > It is added by 18bc0bbd162e3 for pohmelfs and now used by logfs, too. 
> > I didn't noticed that at that time.
> > With git log, any mm guys didn't add Signed-off-by or Reviewed-by.
> > 
> > I think it's not good for file system or module to use it directly. 
> > It would make LRU management harder. 
> 
> How come?

> 
> > Is it really needed? Let's think again. 
> 
> Yes, it is really needed. It is not a some king of low-level mm magic to
> export, but a useful interface to work with LRU lists instead of
> copy-paste it into own machinery.
> 





-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
