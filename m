Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 862BA6B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 02:15:55 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so4697105pab.40
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 23:15:55 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id c7si28880444pat.30.2014.12.07.23.15.52
        for <linux-mm@kvack.org>;
        Sun, 07 Dec 2014 23:15:54 -0800 (PST)
Date: Mon, 8 Dec 2014 16:19:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141208071939.GC3904@js1304-P5Q-DELUXE>
References: <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
 <20141203075747.GB6276@js1304-P5Q-DELUXE>
 <20141204073045.GA2960@cucumber.anchor.net.au>
 <20141205010733.GA13751@js1304-P5Q-DELUXE>
 <20141205055544.GB18326@cucumber.syd4.anchor.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141205055544.GB18326@cucumber.syd4.anchor.net.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Fri, Dec 05, 2014 at 04:55:44PM +1100, Christian Marie wrote:
> On Fri, Dec 05, 2014 at 10:07:33AM +0900, Joonsoo Kim wrote:
> > It looks that there is no stop condition in isolate_freepages(). In
> > this period, your system have not enough freepage and many processes
> > try to find freepage for compaction. Because there is no stop
> > condition, they iterate almost all memory range every time. At the
> > bottom of this mail, I attach one more fix although I don't test it
> > yet. It will cause a lot of allocation failure that your network layer
> > need. It is order 5 allocation request and with __GFP_NOWARN gfp flag,
> > so I assume that there is no problem if allocation request is failed,
> > but, I'm not sure.
> > 
> > watermark check on this patch needs cc->classzone_idx, cc->alloc_flags
> > that comes from Vlastimil's recent change. If you want to test it with
> > 3.18rc5, please remove it. It doesn't much matter.
> > 
> > Anyway, I hope it also helps you.
> 
> Thank you, I will try this next week. If it improves the situation do you think
> that we have a good chance of merging it upstream? I should think that
> backporting such a fix would be a hard sell.

I think that if it improves the situation, it could be merged into upstream.
If the patch fix real issue, it is a candidate for stable tree.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
