Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0033A680FC1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:17:27 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id c7so57494006wjb.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:17:27 -0800 (PST)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.192])
        by mx.google.com with ESMTPS id 5si1487386wrr.176.2017.02.14.09.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 09:17:26 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Tue, 14 Feb 2017 17:17:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE63512@AcuExch.aculab.com>
References: <20170214131206.44b644f6@redhat.com>
        <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
        <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
 <20170214.120426.2032015522492111544.davem@davemloft.net>
In-Reply-To: <20170214.120426.2032015522492111544.davem@davemloft.net>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'David Miller' <davem@davemloft.net>, "ttoukan.linux@gmail.com" <ttoukan.linux@gmail.com>
Cc: "edumazet@google.com" <edumazet@google.com>, "brouer@redhat.com" <brouer@redhat.com>, "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "tariqt@mellanox.com" <tariqt@mellanox.com>, "kafai@fb.com" <kafai@fb.com>, "saeedm@mellanox.com" <saeedm@mellanox.com>, "willemb@google.com" <willemb@google.com>, "bblanco@plumgrid.com" <bblanco@plumgrid.com>, "ast@kernel.org" <ast@kernel.org>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

From: David Miller
> Sent: 14 February 2017 17:04
...
> One path I see around all of this is full integration.  Meaning that
> we can free pages into the page allocator which are still DMA mapped.
> And future allocations from that device are prioritized to take still
> DMA mapped objects.
...

For systems with 'expensive' iommu has anyone tried separating the
allocation of iommu resource (eg page table slots) from their
assignment to physical pages?

Provided the page sizes all match, setting up a receive buffer might
be as simple as writing the physical address into the iommu slot
that matches the ring entry.

Or am I thinking about hardware that is much simpler than real life?

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
