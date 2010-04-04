Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BFE2F6B01FA
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 11:59:53 -0400 (EDT)
Received: by gyg4 with SMTP id 4so1674546gyg.14
        for <linux-mm@kvack.org>; Sun, 04 Apr 2010 08:59:52 -0700 (PDT)
Subject: Re: why are some low-level MM routines being exported?
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <alpine.LFD.2.00.1004041125350.5617@localhost>
References: <alpine.LFD.2.00.1004041125350.5617@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 05 Apr 2010 00:59:44 +0900
Message-ID: <1270396784.1814.92.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Cc: linux-mm@kvack.org, Joern Engel <joern@logfs.org>, Evgeniy Polyakov <zbr@ioremap.net>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-04-04 at 11:27 -0400, Robert P. J. Day wrote:
> perusing the code in mm/filemap.c and i'm curious as to why routines
> like, for example, add_to_page_cache_lru() are being exported.  is it
> really expected that loadable modules might access routines like that
> directly?

It is added by 18bc0bbd162e3 for pohmelfs and now used by logfs, too. 
I didn't noticed that at that time.
With git log, any mm guys didn't add Signed-off-by or Reviewed-by.

I think it's not good for file system or module to use it directly. 
It would make LRU management harder. 

Is it really needed? Let's think again. 

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
