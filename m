Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 451B16B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 17:01:29 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so15431225pac.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 14:01:29 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id kg9si89216pab.53.2015.12.04.14.01.28
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 14:01:28 -0800 (PST)
Date: Fri, 04 Dec 2015 17:01:25 -0500 (EST)
Message-Id: <20151204.170125.1062807391042745453.davem@davemloft.net>
Subject: Re: [PATCH net] atl1c: Improve driver not to do order 4 GFP_ATOMIC
 allocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151204213027.GA6397@amd>
References: <20151204081127.GA29367@amd>
	<20151204.112140.1465149588813636971.davem@davemloft.net>
	<20151204213027.GA6397@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pavel@ucw.cz
Cc: eric.dumazet@gmail.com, mhocko@kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

From: Pavel Machek <pavel@ucw.cz>
Date: Fri, 4 Dec 2015 22:30:27 +0100

> On Fri 2015-12-04 11:21:40, David Miller wrote:
>> From: Pavel Machek <pavel@ucw.cz>
>> Date: Fri, 4 Dec 2015 09:11:27 +0100
>> 
>> >> >>  	if (unlikely(!ring_header->desc)) {
>> >> >> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
>> >> >> +		dev_err(&pdev->dev, "could not get memory for DMA buffer\n");
>> >> >>  		goto err_nomem;
>> >> >>  	}
>> >> >>  	memset(ring_header->desc, 0, ring_header->size);
>> >> >> 
>> >> >> 
>> >> > 
>> >> > So this memset() will really require a different patch to get removed ?
>> >> > 
>> >> > Sigh, not sure why I review patches.
>> >> 
>> >> Agreed, please use dma_zalloc_coherent() and kill that memset().
>> > 
>> > Ok, updated. I'll also add cc: stable, because it makes notebooks with
>> > affected chipset unusable.
>> 
>> Networking patches do not use CC: stable, instead you simply ask me
>> to queue it up and then I batch submit networking fixes to -stable
>> periodically myself.
> 
> Ok, can you take the patch and ignore the Cc, or should I do one more
> iteration?

I took care of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
