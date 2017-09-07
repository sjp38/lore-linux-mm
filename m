Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 306396B0309
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 14:10:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 6so742923pgh.0
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 11:10:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 33si127179ply.600.2017.09.07.11.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Sep 2017 11:10:18 -0700 (PDT)
Date: Thu, 7 Sep 2017 11:10:15 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 04/11] swiotlb: Map the buffer if it was unmapped by
 XPFO
Message-ID: <20170907181015.GA9557@infradead.org>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-5-tycho@docker.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170907173609.22696-5-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

> -	if (PageHighMem(pfn_to_page(pfn))) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {

Please don't sprinkle xpfo details over various bits of code.

Just add a helper with a descriptive name, e.g.

page_is_unmapped()

that also includes the highmem case, as that will easily document
what this check is doing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
