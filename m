Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A4E366B0204
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 14:15:54 -0400 (EDT)
Date: Sun, 4 Apr 2010 22:15:51 +0400
From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: why are some low-level MM routines being exported?
Message-ID: <20100404181550.GA2350@ioremap.net>
References: <alpine.LFD.2.00.1004041125350.5617@localhost> <1270396784.1814.92.camel@barrios-desktop> <20100404160328.GA30540@ioremap.net> <1270398112.1814.114.camel@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1270398112.1814.114.camel@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org, Joern Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 2010 at 01:21:52AM +0900, Minchan Kim (minchan.kim@gmail.com) wrote:
> > > It is added by 18bc0bbd162e3 for pohmelfs and now used by logfs, too. 
> > > I didn't noticed that at that time.
> > > With git log, any mm guys didn't add Signed-off-by or Reviewed-by.
> > > 
> > > I think it's not good for file system or module to use it directly. 
> > > It would make LRU management harder. 
> > 
> > How come?
> 
> What I have a concern is that if file systems or some modules start to
> overuse it to manage pages LRU directly, some mistake of them would make
> system global LRU stupid and make system wrong. 

All filesystems already call it through find_or_create_page() or
grab_page() invoked via read path. In some cases fs has more than
one page grabbed via its internal path where data to be read is
already placed, so it may want just to add those pages into mm lru.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
