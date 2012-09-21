Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BCA4D6B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 12:52:22 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so3337909qcs.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 09:52:21 -0700 (PDT)
Date: Fri, 21 Sep 2012 12:41:13 -0400
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: Re: Query of zram/zsmalloc promotion
Message-ID: <20120921164112.GD4780@phenom.dumpdata.com>
References: <20120912023914.GA31715@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912023914.GA31715@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Wed, Sep 12, 2012 at 11:39:14AM +0900, Minchan Kim wrote:
> Hi all,
> 
> I would like to promote zram/zsmalloc from staging tree.
> I already tried it https://lkml.org/lkml/2012/8/8/37 but I didn't get
> any response from you guys.
> 
> I think zram/zsmalloc's code qulity is good and they
> are used for many embedded vendors for a long time.
> So it's proper time to promote them.
> 
> The zram should put on under driver/block/. I think it's not
> arguable but the issue is which directory we should keep *zsmalloc*.
> 
> Now Nitin want to keep it with zram so it would be in driver/blocks/zram/
> But I don't like it because zsmalloc touches several fields of struct page
> freely(and AFAIRC, Andrew had a same concern with me) so I want to put
> it under mm/.

I like the idea of keeping it in /lib or /mm. Actually 'lib' sounds more
appropriate since it is dealing with storing a bunch of pages in a nice
layout for great density purposes.
> 
> In addtion, now zcache use it, too so it's rather awkward if we put it
> under dirver/blocks/zram/.
> 
> So questions.
> 
> To Andrew:
> Is it okay to put it under mm/ ? Or /lib?
> 
> To Jens:
> Is it okay to put zram under drvier/block/ If you are okay, I will start sending
> patchset after I sort out zsmalloc's location issue.

I would think it would be OK.
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
