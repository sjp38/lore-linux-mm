Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9C4B680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:59:22 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id w194so234852596ybe.2
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:59:22 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id k7si1372186pgk.375.2017.02.14.11.59.21
        for <linux-mm@kvack.org>;
        Tue, 14 Feb 2017 11:59:21 -0800 (PST)
Date: Tue, 14 Feb 2017 14:59:19 -0500 (EST)
Message-Id: <20170214.145919.808498227095540599.davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
From: David Miller <davem@davemloft.net>
In-Reply-To: <20170214203822.72d41268@redhat.com>
References: <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
	<20170214.120426.2032015522492111544.davem@davemloft.net>
	<20170214203822.72d41268@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: brouer@redhat.com
Cc: ttoukan.linux@gmail.com, edumazet@google.com, alexander.duyck@gmail.com, netdev@vger.kernel.org, tariqt@mellanox.com, kafai@fb.com, saeedm@mellanox.com, willemb@google.com, bblanco@plumgrid.com, ast@kernel.org, eric.dumazet@gmail.com, linux-mm@kvack.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 14 Feb 2017 20:38:22 +0100

> On Tue, 14 Feb 2017 12:04:26 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> One path I see around all of this is full integration.  Meaning that
>> we can free pages into the page allocator which are still DMA mapped.
>> And future allocations from that device are prioritized to take still
>> DMA mapped objects.
> 
> I like this idea.  Are you saying that this should be done per DMA
> engine or per device?
> 
> If this is per device, it is almost the page_pool idea.  

Per-device is simplest, at least at first.

Maybe later down the road we can try to pool by "mapping entity" be
that a parent IOMMU or something else like a hypervisor managed
page table.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
