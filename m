Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 7F1656B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 00:36:10 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id qd12so2831648ieb.0
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 21:36:09 -0700 (PDT)
Date: Fri, 16 Aug 2013 13:35:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130816043556.GA6216@gmail.com>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <CAA25o9Q1KVHEzdeXJFe9A8K9MULysq_ShWrUBZM4-h=5vmaQ8w@mail.gmail.com>
 <20130814161753.GB2706@gmail.com>
 <520d883a.a2f6420a.6f36.0d66SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520d883a.a2f6420a.6f36.0d66SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Luigi Semenzato <semenzato@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

Hi,

On Fri, Aug 16, 2013 at 10:02:08AM +0800, Wanpeng Li wrote:
> Hi Minchan,
> On Thu, Aug 15, 2013 at 01:17:53AM +0900, Minchan Kim wrote:
> >Hi Luigi,
> >
> >On Wed, Aug 14, 2013 at 08:53:31AM -0700, Luigi Semenzato wrote:
> >> During earlier discussions of zswap there was a plan to make it work
> >> with zsmalloc as an option instead of zbud. Does zbud work for
> >
> >AFAIR, it was not an optoin but zsmalloc was must but there were
> >several objections because zswap's notable feature is to dump
> >compressed object to real swap storage. For that, zswap needs to
> >store bounded objects in a zpage so that dumping could be bounded, too.
> >Otherwise, it could encounter OOM easily.
> >
> >> compression factors better than 2:1?  I have the impression (maybe
> >> wrong) that it does not.  In our use of zram (Chrome OS) typical
> >
> >Since zswap changed allocator from zsmalloc to zbud, I didn't follow
> >because I had no interest of low compressoin ratio allocator so
> >I have no idea of status of zswap at a moment but I guess it would be
> >still 2:1.
> >
> >> overall compression ratios are between 2.5:1 and 3:1.  We would hate
> >> to waste that memory if we switch to zswap.
> >
> >If you have real swap storage, zswap might be better although I have
> >no number but real swap is money for embedded system and it has sudden
> >garbage collection on firmware side if we use eMMC or SSD so that it
> >could affect system latency. Morever, if we start to use real swap,
> >maybe we should encrypt the data and it would be severe overhead(CPU
> >and Power).
> >
> 
> Why real swap for embedded system need encrypt the data? I think there
> is no encrypt for data against server and desktop.

I have used some portable device but suddenly, I lost it or was stolen.
A hacker can pick it up and read my swap and found my precious information.
I don't want it. I guess it's one of reason ChromeOS don't want to use real
swap.

https://groups.google.com/a/chromium.org/forum/#!msg/chromium-os-discuss/92Fvi4Ezego/ZvbrC3L2FG4J

> 
> >And what I am considering after promoting for zram feature is
> >asynchronous I/O and it's possible because zram is block device.
> >
> >Thanks!
> >-- 
> >Kind regards,
> >Minchan Kim
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
