Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1EF6B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:39:59 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 75so31898454ite.7
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:39:59 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [69.252.207.43])
        by mx.google.com with ESMTPS id 78si9640496ith.107.2016.12.15.08.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 08:39:58 -0800 (PST)
Date: Thu, 15 Dec 2016 10:38:53 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
In-Reply-To: <20161215092841.2f7065b5@redhat.com>
Message-ID: <alpine.DEB.2.20.1612151034140.9073@east.gentwo.org>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org> <20161213171028.24dbf519@redhat.com> <5850335F.6090000@gmail.com> <20161213.145333.514056260418695987.davem@davemloft.net> <58505535.1080908@gmail.com> <20161214103914.3a9ebbbf@redhat.com>
 <5851740A.2080806@gmail.com> <CAKgT0UfnBurxz9f+ceD81hAp3U0tGHEi_5MEtxk6PiehG=X8ag@mail.gmail.com> <20161214222927.587a8ac4@redhat.com> <CAKgT0UfckuW-qPOr3WAgwKJFGu0Ot0g2Ha3uRpyU3rpdZeFVpA@mail.gmail.com> <20161215092841.2f7065b5@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, John Fastabend <john.fastabend@gmail.com>, David Miller <davem@davemloft.net>, rppt@linux.vnet.ibm.com, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, willemdebruijn.kernel@gmail.com, =?ISO-8859-15?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>, magnus.karlsson@intel.com, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, METH@il.ibm.com, Vlad Yasevich <vyasevich@gmail.com>

On Thu, 15 Dec 2016, Jesper Dangaard Brouer wrote:

> > It sounds like Christoph's RDMA approach might be the way to go.
>
> I'm getting more and more fond of Christoph's RDMA approach.  I do
> think we will end-up with something close to that approach.  I just
> wanted to get review on my idea first.
>
> IMHO the major blocker for the RDMA approach is not HW filters
> themselves, but a common API that applications can call to register
> what goes into the HW queues in the driver.  I suspect it will be a
> long project agreeing between vendors.  And agreeing on semantics.

Some of the methods from the RDMA subsystem (like queue pairs, the various
queues etc) could be extracted and used here. Multiple vendors already
support these features and some devices operate both in an RDMA and a
network stack mode. Having that all supported by the networks stack would
reduce overhead for those vendors.

Multiple new vendors are coming up in the RDMA subsystem because the
regular network stack does not have the right performance for high speed
networking. I would rather see them have a way to get that functionality
from the regular network stack. Please add some extensions so that the
RDMA style I/O can be made to work. Even the hardware of the new NICs is
already prepared to work with the data structures of the RDMA subsystem.
That provides an area of standardization where we could hook into but do
that properly and in a nice way in the context of main stream network
support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
