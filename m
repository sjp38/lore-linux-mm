Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B4DB36B0038
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 02:54:20 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so15186606pac.22
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 23:54:20 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id us1si13710712pac.23.2014.12.02.23.54.17
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 23:54:19 -0800 (PST)
Date: Wed, 3 Dec 2014 16:57:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141203075747.GB6276@js1304-P5Q-DELUXE>
References: <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Tue, Dec 02, 2014 at 04:06:08PM +1100, Christian Marie wrote:
> On Tue, Dec 02, 2014 at 01:53:24PM +0900, Joonsoo Kim wrote:
> > This is just my assumption, so if possible, please check it with
> > compaction tracepoint. If it is, we can make a solution for this
> > problem.
> 
> Which event/function would you like me to trace specifically?

Hello,

It'd be very helpful to get output of
"trace_event=compaction:*,kmem:mm_page_alloc_extfrag" on the kernel
with my tracepoint patches below.

See following link. There is 3 patches.

https://lkml.org/lkml/2014/12/3/71

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
