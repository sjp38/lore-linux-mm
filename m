Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBADC6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 16:22:34 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 81so48825456iog.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 13:22:34 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id p184si39023333iod.1.2016.12.14.13.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 13:22:34 -0800 (PST)
Date: Wed, 14 Dec 2016 15:22:30 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
In-Reply-To: <c122d91d-9506-ac35-29e5-3d80791259ef@stressinduktion.org>
Message-ID: <alpine.DEB.2.20.1612141520350.24815@east.gentwo.org>
References: <20161205153132.283fcb0e@redhat.com> <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com> <20161212141433.GB19987@rapoport-lnx> <584EB8DF.8000308@gmail.com> <20161212181344.3ddfa9c3@redhat.com> <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <8aea213f-2739-9bd3-3a6a-668b759336ae@stressinduktion.org> <alpine.DEB.2.20.1612141059020.20959@east.gentwo.org> <063D6719AE5E284EB5DD2968C1650D6DB023FA6E@AcuExch.aculab.com> <alpine.DEB.2.20.1612141342080.23516@east.gentwo.org>
 <c122d91d-9506-ac35-29e5-3d80791259ef@stressinduktion.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: David Laight <David.Laight@ACULAB.COM>, Jesper Dangaard Brouer <brouer@redhat.com>, John Fastabend <john.fastabend@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?ISO-8859-15?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>, Vladislav Yasevich <vyasevich@gmail.com>

On Wed, 14 Dec 2016, Hannes Frederic Sowa wrote:

> Wouldn't changing of the pages cause expensive TLB flushes?

Yes so you would only want that feature if its realized at the page
table level for debugging issues.

Once you have memory registered with the hardware device then also the
device could itself could perform snooping to realize that data was
changed and thus abort the operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
