Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 707CD6B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:30:11 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id h3-v6so1037026wrr.15
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:30:11 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i17-v6si19881767wrr.17.2018.10.11.06.30.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 06:30:10 -0700 (PDT)
Date: Thu, 11 Oct 2018 15:30:09 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/5] mm/sparse: add common helper to mark all memblocks
 present
Message-ID: <20181011133009.GA7276@lst.de>
References: <20181005161642.2462-1-logang@deltatee.com> <20181005161642.2462-2-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181005161642.2462-2-logang@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.de>

> +	for_each_memblock(memory, reg) {
> +		int nid = memblock_get_region_node(reg);
> +
> +		memory_present(nid, memblock_region_memory_base_pfn(reg),
> +			       memblock_region_memory_end_pfn(reg));

Any reason you have a local variable for the node id while you happily
get away without one for the others?  Why not simply:

	for_each_memblock(memory, reg) {
		memory_present(memblock_get_region_node(reg)
			       memblock_region_memory_base_pfn(reg),
			       memblock_region_memory_end_pfn(reg));
	}
