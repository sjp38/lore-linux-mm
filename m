Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6F38E6B0260
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 11:21:46 -0500 (EST)
Received: by pfnn128 with SMTP id n128so28311265pfn.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 08:21:46 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id f2si15061892pas.200.2015.12.04.08.21.45
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 08:21:45 -0800 (PST)
Date: Fri, 04 Dec 2015 11:21:40 -0500 (EST)
Message-Id: <20151204.112140.1465149588813636971.davem@davemloft.net>
Subject: Re: [PATCH net] atl1c: Improve driver not to do order 4 GFP_ATOMIC
 allocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151204081127.GA29367@amd>
References: <1449163048.25029.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151203.123249.2158644928982094593.davem@davemloft.net>
	<20151204081127.GA29367@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pavel@ucw.cz
Cc: eric.dumazet@gmail.com, mhocko@kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

From: Pavel Machek <pavel@ucw.cz>
Date: Fri, 4 Dec 2015 09:11:27 +0100

>> >>  	if (unlikely(!ring_header->desc)) {
>> >> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
>> >> +		dev_err(&pdev->dev, "could not get memory for DMA buffer\n");
>> >>  		goto err_nomem;
>> >>  	}
>> >>  	memset(ring_header->desc, 0, ring_header->size);
>> >> 
>> >> 
>> > 
>> > So this memset() will really require a different patch to get removed ?
>> > 
>> > Sigh, not sure why I review patches.
>> 
>> Agreed, please use dma_zalloc_coherent() and kill that memset().
> 
> Ok, updated. I'll also add cc: stable, because it makes notebooks with
> affected chipset unusable.

Networking patches do not use CC: stable, instead you simply ask me
to queue it up and then I batch submit networking fixes to -stable
periodically myself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
