Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id E76946B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 13:39:24 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id q13so63556746vkd.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 10:39:24 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 103si13649152uas.13.2016.12.13.10.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 10:39:23 -0800 (PST)
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
References: <20161205153132.283fcb0e@redhat.com>
 <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com>
 <20161212141433.GB19987@rapoport-lnx> <584EB8DF.8000308@gmail.com>
 <20161212181344.3ddfa9c3@redhat.com>
 <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com>
From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Message-ID: <8aea213f-2739-9bd3-3a6a-668b759336ae@stressinduktion.org>
Date: Tue, 13 Dec 2016 19:39:17 +0100
MIME-Version: 1.0
In-Reply-To: <20161213171028.24dbf519@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, Christoph Lameter <cl@linux.com>
Cc: John Fastabend <john.fastabend@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>, Vladislav Yasevich <vyasevich@gmail.com>

On 13.12.2016 17:10, Jesper Dangaard Brouer wrote:
>> What is bad about RDMA is that it is a separate kernel subsystem.
>> What I would like to see is a deeper integration with the network
>> stack so that memory regions can be registred with a network socket
>> and work requests then can be submitted and processed that directly
>> read and write in these regions. The network stack should provide the
>> services that the hardware of the NIC does not suppport as usual.
> 
> Interesting.  So you even imagine sockets registering memory regions
> with the NIC.  If we had a proper NIC HW filter API across the drivers,
> to register the steering rule (like ibv_create_flow), this would be
> doable, but we don't (DPDK actually have an interesting proposal[1])

On a side note, this is what windows does with RIO ("registered I/O").
Maybe you want to look at the API to get some ideas: allocating and
pinning down memory in user space and registering that with sockets to
get zero-copy IO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
