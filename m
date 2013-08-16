Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 511FA6B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 03:02:59 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1VAE3k-0001Bs-SO
	for linux-mm@kvack.org; Fri, 16 Aug 2013 09:02:56 +0200
Received: from c-50-132-41-203.hsd1.wa.comcast.net ([50.132.41.203])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 16 Aug 2013 09:02:56 +0200
Received: from eternaleye by c-50-132-41-203.hsd1.wa.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 16 Aug 2013 09:02:56 +0200
From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Date: Fri, 16 Aug 2013 00:02:45 -0700
Message-ID: <kukiqe$j4b$2@ger.gmane.org>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org> <CAA25o9Q1KVHEzdeXJFe9A8K9MULysq_ShWrUBZM4-h=5vmaQ8w@mail.gmail.com> <20130814161753.GB2706@gmail.com> <520d883a.a2f6420a.6f36.0d66SMTPIN_ADDED_BROKEN@mx.google.com> <20130816043556.GA6216@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Minchan Kim wrote:

> Hi,
> 
> On Fri, Aug 16, 2013 at 10:02:08AM +0800, Wanpeng Li wrote:
>> Hi Minchan,
>> On Thu, Aug 15, 2013 at 01:17:53AM +0900, Minchan Kim wrote:
>> >Hi Luigi,
>> >
>> >On Wed, Aug 14, 2013 at 08:53:31AM -0700, Luigi Semenzato wrote:
>> >If you have real swap storage, zswap might be better although I have
>> >no number but real swap is money for embedded system and it has sudden
>> >garbage collection on firmware side if we use eMMC or SSD so that it
>> >could affect system latency. Morever, if we start to use real swap,
>> >maybe we should encrypt the data and it would be severe overhead(CPU
>> >and Power).
>> >
>> 
>> Why real swap for embedded system need encrypt the data? I think there
>> is no encrypt for data against server and desktop.
> 
> I have used some portable device but suddenly, I lost it or was stolen.
> A hacker can pick it up and read my swap and found my precious
> information. I don't want it. I guess it's one of reason ChromeOS don't
> want to use real swap.
> 
> https://groups.google.com/a/chromium.org/forum/#!msg/chromium-os-discuss/92Fvi4Ezego/ZvbrC3L2FG4J

This is when you use dm-crypt. Also, as noted by others, zswap with a fake
backing device that always returns failure (and thus never stores data on 
disk) should behave like zram without any physical swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
