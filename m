Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6C76B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:27:00 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id o17so24656748pli.7
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:27:00 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h4si6885741pgc.54.2017.12.28.23.26.58
        for <linux-mm@kvack.org>;
        Thu, 28 Dec 2017 23:26:58 -0800 (PST)
Date: Fri, 29 Dec 2017 16:26:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zram: better utilization of zram swap space
Message-ID: <20171229072656.GA10366@bbox>
References: <CGME20171222103443epcas5p41f45e1a99146aac89edd63f76a3eb62a@epcas5p4.samsung.com>
 <1513938606-17735-1-git-send-email-gopi.st@samsung.com>
 <20171227062946.GA11295@bgram>
 <20171227071056.GA471@jagdpanzerIV>
 <20171228000004.GB10532@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171228000004.GB10532@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, gopi.st@samsung.com
Cc: ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, v.narang@samsung.com, pankaj.m@samsung.com, a.sahrawat@samsung.com, prakash.a@samsung.com, himanshu.sh@samsung.com, lalit.mohan@samsung.com

On Thu, Dec 28, 2017 at 09:00:04AM +0900, Minchan Kim wrote:
> On Wed, Dec 27, 2017 at 04:10:56PM +0900, Sergey Senozhatsky wrote:
> > On (12/27/17 15:29), Minchan Kim wrote:
> > > On Fri, Dec 22, 2017 at 04:00:06PM +0530, Gopi Sai Teja wrote:
> > > > 75% of the PAGE_SIZE is not a correct threshold to store uncompressed
> > > 
> > > Please describe it in detail that why current threshold is bad in that
> > > memory efficiency point of view.
> > > 
> > > > pages in zs_page as this must be changed if the maximum pages stored
> > > > in zspage changes. Instead using zs classes, we can set the correct
> > > 
> > > Also, let's include the pharase Sergey pointed out in this description.
> > > 
> > > It's not a good idea that zram need to know allocator's implementation
> > > with harded value like 75%.
> > 
> > so I don't like that, basically, my work and my findings are
> > now submitted by someone else without even crediting my work.
> > not to mention that I like my commit message much better.
> > 
> > 	-ss
> 
> Gopi Sai Teja, please discuss with Sergey about patch credit.

Hi Gopi Sai Teja,

Now I read previous thread at v1 carefully, I found Sergey already
sent a patch long time ago which is almost same one I suggested.
And he told he will send a patch soon so I want to wait his patch.
We are approaching rc6 now so it's not urgent.

Sergey, sorry for missing your patch at that time.
Could you resend your patch when you have a time? Please think
over better name of the function "zs_get_huge_class_size_watermark"

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
