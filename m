Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id B5BF06B0259
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:27:57 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id j125so38064684oih.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:27:57 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0092.outbound.protection.outlook.com. [157.56.112.92])
        by mx.google.com with ESMTPS id ok6si6235253oeb.2.2016.02.25.03.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 03:27:56 -0800 (PST)
Subject: Re: [RFC 0/7] Peer-direct memory
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com>
 <20160212201328.GA14122@infradead.org>
 <20160212203649.GA10540@obsidianresearch.com>
 <56C09C7E.4060808@dev.mellanox.co.il>
 <36F6EBABA23FEF4391AF72944D228901EB70C102@BBYEXM01.pmc-sierra.internal>
 <56C97E13.9090101@mellanox.com>
 <36F6EBABA23FEF4391AF72944D228901EB712F72@BBYEXM01.pmc-sierra.internal>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <56CEE531.5050807@mellanox.com>
Date: Thu, 25 Feb 2016 13:27:45 +0200
MIME-Version: 1.0
In-Reply-To: <36F6EBABA23FEF4391AF72944D228901EB712F72@BBYEXM01.pmc-sierra.internal>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Bates <Stephen.Bates@pmcs.com>, Sagi Grimberg <sagig@dev.mellanox.co.il>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Christoph Hellwig <hch@infradead.org>, "'Logan Gunthorpe' (logang@deltatee.com)" <logang@deltatee.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Leon Romanovsky <leonro@mellanox.com>, "sagig@mellanox.com" <sagig@mellanox.com>

On 25/02/2016 01:45, Stephen Bates wrote:
> Great, we hope to have the RFC soon. It will be able to accept different flags for devm_memremap() call with regards to caching. Though one question I have is when does the caching flag affect Peer-2-Peer memory accesses? I can see caching causing issues when performing accesses from the CPU but P2P accesses should bypass any caches in the system?
I don't think the caching flag will affect peer to peer directly, but we need 
to keep the BAR mapped to the host the same way it is today. If we change the
driver to map page structs returned from devm_memremap_pages() instead of using
io_remap_pfn_range() it needs to continue working with host uses and not only
with peers.

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
