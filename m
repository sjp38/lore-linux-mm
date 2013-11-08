Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 744156B0188
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 21:00:52 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so1452400pde.15
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 18:00:52 -0800 (PST)
Received: from psmtp.com ([74.125.245.192])
        by mx.google.com with SMTP id it5si4575349pbc.245.2013.11.07.18.00.50
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 18:00:51 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so1495517pab.12
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 18:00:49 -0800 (PST)
Date: Thu, 7 Nov 2013 18:02:21 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: Ensure handle is never 0 on success
Message-ID: <20131108020221.GA28001@kroah.com>
References: <20131107070451.GA10645@bbox>
 <CAA25o9TaWG7Wu6uXwyapKD1oaVYqb47_9Ag7JbT-ZyQT7iaJEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9TaWG7Wu6uXwyapKD1oaVYqb47_9Ag7JbT-ZyQT7iaJEA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, lliubbo@gmail.com, jmarchan@redhat.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Nov 07, 2013 at 09:06:26AM -0800, Luigi Semenzato wrote:
> If I may add my usual 2c (and some news):
> 
> zram is used by default on all Chrome OS devices.  I can't say how
> many devices, but it's not a small number, google it, and it's an
> important market, low-end laptops for education and the less affluent.
>  It has been available experimentally for well over a year.
> 
> Android 4.4 KitKat is also using zram, to better support devices with
> less than 1 MB RAM.  (That's the news.)
> 
> When comparing the relative advantages of the two subsystems (zram and
> zswap), let's not forget that considerable effort goes into in tuning
> and bug fixing for specific use cases---possibly even more than the
> initial development effort.  Zram has not just been sitting around in
> drivers/staging, it's in serious use.
> 
> If we were to judge systems based merely on theoretical technical
> merit, then we should consider switching en masse to FreeBSD.  (I said
> we should *consider* :).
> 
> I am very familiar with the limitations of zram, but it works well and
> I think it would be wise to keep supporting it.  Besides, it's small
> and AFAICT it interfaces cleanly with the rest of the system, so I
> don't see what the big deal is.

Then please help with getting it merged properly, and out of staging.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
