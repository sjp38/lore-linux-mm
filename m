Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E68506B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 11:23:43 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n5so125034029pfn.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:23:43 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0068.outbound.protection.outlook.com. [157.56.112.68])
        by mx.google.com with ESMTPS id ua9si2530958pab.25.2016.03.17.08.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 08:18:20 -0700 (PDT)
Subject: Re: [PATCH RFC 1/1] Add support for ZONE_DEVICE IO memory with struct
 pages.
References: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
 <20160314212344.GC23727@linux.intel.com>
 <20160314215708.GA7282@obsidianresearch.com>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <56EACAB3.5070301@mellanox.com>
Date: Thu, 17 Mar 2016 17:18:11 +0200
MIME-Version: 1.0
In-Reply-To: <20160314215708.GA7282@obsidianresearch.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: Stephen Bates <stephen.bates@pmcs.com>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-nvdimm@ml01.01.org, javier@cnexlabs.com, sagig@mellanox.com, leonro@mellanox.com, artemyko@mellanox.com, hch@infradead.org

On 3/14/2016 11:57 PM, Jason Gunthorpe wrote:
> The other issue is that the fencing mechanism RDMA uses to create
> ordering with system memory is not good enough to fence peer-peer
> transactions in the general case. It is only possibly good enough if
> all the transactions run through the root complex.

Are you sure this is a problem? I'm not sure it is clear in the PCIe 
specs, but I thought that for transactions that are not relaxed-ordered 
and don't use ID-based ordering, a PCIe switch must prevent reads and 
writes from passing writes. I assume this is true even when the requestor
ID is different because IDO relaxes these constraints specifically
for transactions coming from different requestor IDs.

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
