Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CEFD76B0009
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 03:50:24 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id x65so7911404pfb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 00:50:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id n81si593955pfi.46.2016.02.17.00.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 00:50:24 -0800 (PST)
Date: Wed, 17 Feb 2016 00:49:59 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 0/7] Peer-direct memory
Message-ID: <20160217084959.GB13616@infradead.org>
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com>
 <56C08EC8.10207@mellanox.com>
 <20160216182212.GA21071@obsidianresearch.com>
 <CAPSaadxbFCOcKV=c3yX7eGw9Wqzn3jvPRZe2LMWYmiQcijT4nw@mail.gmail.com>
 <CAPSaadx3vNBSxoWuvjrTp2n8_-DVqofttFGZRR+X8zdWwV86nw@mail.gmail.com>
 <20160217044417.GA25049@obsidianresearch.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160217044417.GA25049@obsidianresearch.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: davide rossetti <davide.rossetti@gmail.com>, Haggai Eran <haggaie@mellanox.com>, Kovalyov Artemy <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "leon@leon.ro" <leon@leon.ro>, Sagi Grimberg <sagig@mellanox.com>

On Tue, Feb 16, 2016 at 09:44:17PM -0700, Jason Gunthorpe wrote:
> On Tue, Feb 16, 2016 at 08:13:58PM -0800, davide rossetti wrote:
> 
> > Bottom line is, BAR mappings are not like plain memory.
> 
> As I understand it the actual use of this in fact when user space
> manages to map BAR memory into it's address space and attempts to do DMA
> from it. So, I'm not sure I agree at all with this assement.
> 
> ie I gather with NVMe the desire is this could happen through the
> filesystem with the right open/mmap flags.

Lot's of confusion here.  NVMe is a block device interface - there
is not real point in mapping anything in there to userspace unless
you use an entirely userspace driver through the normal userspace
PCI driver interface.  For pmem (which some people confusingly call
NVM) mapping the byte addressable persistent memory to userspace using
DAX makes a lot of sense, and a lot of work around that is going
on currently.

For NVMe 1.2 there is a new feature called the controller memory
buffer, which basically is a giant BAR that can be used instead
of host memory for the submission and completion queues of the
device, as well as for actual data sent to and reived from the device.

Some people are tlaking about using this as the target of RDMA
operations, but I don't think this patch series would be anywhere
near useful for this mode of operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
