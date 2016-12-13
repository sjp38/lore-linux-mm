Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAED86B0069
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 14:53:43 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so178781834pfg.0
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 11:53:43 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id 33si49190197pli.217.2016.12.13.11.53.42
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 11:53:42 -0800 (PST)
Date: Tue, 13 Dec 2016 14:53:33 -0500 (EST)
Message-Id: <20161213.145333.514056260418695987.davem@davemloft.net>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
From: David Miller <davem@davemloft.net>
In-Reply-To: <5850335F.6090000@gmail.com>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
	<20161213171028.24dbf519@redhat.com>
	<5850335F.6090000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.fastabend@gmail.com
Cc: brouer@redhat.com, cl@linux.com, rppt@linux.vnet.ibm.com, netdev@vger.kernel.org, linux-mm@kvack.org, willemdebruijn.kernel@gmail.com, bjorn.topel@intel.com, magnus.karlsson@intel.com, alexander.duyck@gmail.com, mgorman@techsingularity.net, tom@herbertland.com, bblanco@plumgrid.com, tariqt@mellanox.com, saeedm@mellanox.com, jesse.brandeburg@intel.com, METH@il.ibm.com, vyasevich@gmail.com

From: John Fastabend <john.fastabend@gmail.com>
Date: Tue, 13 Dec 2016 09:43:59 -0800

> What does "zero-copy send packet-pages to the application/socket that
> requested this" mean? At the moment on x86 page-flipping appears to be
> more expensive than memcpy (I can post some data shortly) and shared
> memory was proposed and rejected for security reasons when we were
> working on bifurcated driver.

The whole idea is that we map all the active RX ring pages into
userspace from the start.

And just how Jesper's page pool work will avoid DMA map/unmap,
it will also avoid changing the userspace mapping of the pages
as well.

Thus avoiding the TLB/VM overhead altogether.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
