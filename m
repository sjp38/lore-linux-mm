Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFAA6B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 10:24:42 -0500 (EST)
Date: Mon, 11 Jan 2010 07:20:56 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Free memory when create_device is failed
Message-ID: <20100111152056.GB26725@kroah.com>
References: <20100111161553.3acebae9.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100111161553.3acebae9.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 11, 2010 at 04:15:53PM +0900, Minchan Kim wrote:
> 	
> Hi, Greg.
> 
> I don't know where I send this patch.
> Do I send this patch to akpm or only you and LKML?

Look at the drivers/staging/ramzswap/TODO file, and also use the
scripts/get_maintainer.pl script to determine the correct people and
mailing lists to send patches to in the future.

I'll queue this up later this week.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
