Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFD256B0253
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 12:01:15 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id j198so42547234oih.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:01:15 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [69.252.207.41])
        by mx.google.com with ESMTPS id c201si26763709oih.316.2016.12.14.09.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 09:01:15 -0800 (PST)
Date: Wed, 14 Dec 2016 11:00:12 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
In-Reply-To: <8aea213f-2739-9bd3-3a6a-668b759336ae@stressinduktion.org>
Message-ID: <alpine.DEB.2.20.1612141059020.20959@east.gentwo.org>
References: <20161205153132.283fcb0e@redhat.com> <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com> <20161212141433.GB19987@rapoport-lnx> <584EB8DF.8000308@gmail.com> <20161212181344.3ddfa9c3@redhat.com> <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <8aea213f-2739-9bd3-3a6a-668b759336ae@stressinduktion.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, John Fastabend <john.fastabend@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?ISO-8859-15?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>, Vladislav Yasevich <vyasevich@gmail.com>

On Tue, 13 Dec 2016, Hannes Frederic Sowa wrote:

> > Interesting.  So you even imagine sockets registering memory regions
> > with the NIC.  If we had a proper NIC HW filter API across the drivers,
> > to register the steering rule (like ibv_create_flow), this would be
> > doable, but we don't (DPDK actually have an interesting proposal[1])
>
> On a side note, this is what windows does with RIO ("registered I/O").
> Maybe you want to look at the API to get some ideas: allocating and
> pinning down memory in user space and registering that with sockets to
> get zero-copy IO.

Yup that is also what I think. Regarding the memory registration and flow
steering for user space RX/TX ring please look at the qpair model
implemented by the RDMA subsystem in the kernel. The memory semantics are
clearly established there and have been in use for more than a decade.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
