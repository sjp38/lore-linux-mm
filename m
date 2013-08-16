From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Date: Fri, 16 Aug 2013 10:02:08 +0800
Message-ID: <34116.0130723894$1376618561@news.gmane.org>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <CAA25o9Q1KVHEzdeXJFe9A8K9MULysq_ShWrUBZM4-h=5vmaQ8w@mail.gmail.com>
 <20130814161753.GB2706@gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VA9N3-0007hM-9b
	for glkm-linux-mm-2@m.gmane.org; Fri, 16 Aug 2013 04:02:33 +0200
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id BFBE06B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 22:02:30 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 16 Aug 2013 11:51:32 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9749F3578057
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 12:02:20 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7G1kLig7602596
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 11:46:29 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7G22ASJ017044
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 12:02:12 +1000
Content-Disposition: inline
In-Reply-To: <20130814161753.GB2706@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Luigi Semenzato <semenzato@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

Hi Minchan,
On Thu, Aug 15, 2013 at 01:17:53AM +0900, Minchan Kim wrote:
>Hi Luigi,
>
>On Wed, Aug 14, 2013 at 08:53:31AM -0700, Luigi Semenzato wrote:
>> During earlier discussions of zswap there was a plan to make it work
>> with zsmalloc as an option instead of zbud. Does zbud work for
>
>AFAIR, it was not an optoin but zsmalloc was must but there were
>several objections because zswap's notable feature is to dump
>compressed object to real swap storage. For that, zswap needs to
>store bounded objects in a zpage so that dumping could be bounded, too.
>Otherwise, it could encounter OOM easily.
>
>> compression factors better than 2:1?  I have the impression (maybe
>> wrong) that it does not.  In our use of zram (Chrome OS) typical
>
>Since zswap changed allocator from zsmalloc to zbud, I didn't follow
>because I had no interest of low compressoin ratio allocator so
>I have no idea of status of zswap at a moment but I guess it would be
>still 2:1.
>
>> overall compression ratios are between 2.5:1 and 3:1.  We would hate
>> to waste that memory if we switch to zswap.
>
>If you have real swap storage, zswap might be better although I have
>no number but real swap is money for embedded system and it has sudden
>garbage collection on firmware side if we use eMMC or SSD so that it
>could affect system latency. Morever, if we start to use real swap,
>maybe we should encrypt the data and it would be severe overhead(CPU
>and Power).
>

Why real swap for embedded system need encrypt the data? I think there
is no encrypt for data against server and desktop.

>And what I am considering after promoting for zram feature is
>asynchronous I/O and it's possible because zram is block device.
>
>Thanks!
>-- 
>Kind regards,
>Minchan Kim
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
