Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 820D26B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 19:00:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p14so4076640pgq.2
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 16:00:07 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y4si7785422pgv.74.2017.12.27.16.00.05
        for <linux-mm@kvack.org>;
        Wed, 27 Dec 2017 16:00:06 -0800 (PST)
Date: Thu, 28 Dec 2017 09:00:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zram: better utilization of zram swap space
Message-ID: <20171228000004.GB10532@bbox>
References: <CGME20171222103443epcas5p41f45e1a99146aac89edd63f76a3eb62a@epcas5p4.samsung.com>
 <1513938606-17735-1-git-send-email-gopi.st@samsung.com>
 <20171227062946.GA11295@bgram>
 <20171227071056.GA471@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227071056.GA471@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Gopi Sai Teja <gopi.st@samsung.com>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, v.narang@samsung.com, pankaj.m@samsung.com, a.sahrawat@samsung.com, prakash.a@samsung.com, himanshu.sh@samsung.com, lalit.mohan@samsung.com

On Wed, Dec 27, 2017 at 04:10:56PM +0900, Sergey Senozhatsky wrote:
> On (12/27/17 15:29), Minchan Kim wrote:
> > On Fri, Dec 22, 2017 at 04:00:06PM +0530, Gopi Sai Teja wrote:
> > > 75% of the PAGE_SIZE is not a correct threshold to store uncompressed
> > 
> > Please describe it in detail that why current threshold is bad in that
> > memory efficiency point of view.
> > 
> > > pages in zs_page as this must be changed if the maximum pages stored
> > > in zspage changes. Instead using zs classes, we can set the correct
> > 
> > Also, let's include the pharase Sergey pointed out in this description.
> > 
> > It's not a good idea that zram need to know allocator's implementation
> > with harded value like 75%.
> 
> so I don't like that, basically, my work and my findings are
> now submitted by someone else without even crediting my work.
> not to mention that I like my commit message much better.
> 
> 	-ss

Gopi Sai Teja, please discuss with Sergey about patch credit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
