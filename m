Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9C09F6B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 03:11:31 -0500 (EST)
Received: by wmvv187 with SMTP id v187so62619611wmv.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 00:11:30 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id 202si4233173wmv.39.2015.12.04.00.11.29
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 00:11:30 -0800 (PST)
Date: Fri, 4 Dec 2015 09:11:27 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH net] atl1c: Improve driver not to do order 4 GFP_ATOMIC
 allocation
Message-ID: <20151204081127.GA29367@amd>
References: <20151128145113.GB4135@amd>
 <20151203155905.GA31974@amd>
 <1449163048.25029.2.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151203.123249.2158644928982094593.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203.123249.2158644928982094593.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: eric.dumazet@gmail.com, mhocko@kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

> >>  	if (unlikely(!ring_header->desc)) {
> >> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
> >> +		dev_err(&pdev->dev, "could not get memory for DMA buffer\n");
> >>  		goto err_nomem;
> >>  	}
> >>  	memset(ring_header->desc, 0, ring_header->size);
> >> 
> >> 
> > 
> > So this memset() will really require a different patch to get removed ?
> > 
> > Sigh, not sure why I review patches.
> 
> Agreed, please use dma_zalloc_coherent() and kill that memset().

Ok, updated. I'll also add cc: stable, because it makes notebooks with
affected chipset unusable.

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
