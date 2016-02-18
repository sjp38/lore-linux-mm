Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 01E4B828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:12:38 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id y8so18814675igp.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:12:37 -0800 (PST)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id n139si14500511ion.6.2016.02.18.09.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 09:12:37 -0800 (PST)
Date: Thu, 18 Feb 2016 10:12:03 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC 0/7] Peer-direct memory
Message-ID: <20160218171203.GA3827@obsidianresearch.com>
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com>
 <56C08EC8.10207@mellanox.com>
 <20160216182212.GA21071@obsidianresearch.com>
 <CAPSaadxbFCOcKV=c3yX7eGw9Wqzn3jvPRZe2LMWYmiQcijT4nw@mail.gmail.com>
 <CAPSaadx3vNBSxoWuvjrTp2n8_-DVqofttFGZRR+X8zdWwV86nw@mail.gmail.com>
 <20160217044417.GA25049@obsidianresearch.com>
 <20160217084959.GB13616@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160217084959.GB13616@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: davide rossetti <davide.rossetti@gmail.com>, Haggai Eran <haggaie@mellanox.com>, Kovalyov Artemy <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "leon@leon.ro" <leon@leon.ro>, Sagi Grimberg <sagig@mellanox.com>

On Wed, Feb 17, 2016 at 12:49:59AM -0800, Christoph Hellwig wrote:

> PCI driver interface.  For pmem (which some people confusingly call
> NVM) mapping the byte addressable persistent memory to userspace using
> DAX makes a lot of sense, and a lot of work around that is going
> on currently.

Right, this is what I was refering to, 'pmem' like capability done
with NVMe hardware on PCIe.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
