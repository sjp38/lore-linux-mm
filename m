Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56F716B026E
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:09:01 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id r88so5829757pfi.23
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:09:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t3si3793799pgf.710.2017.12.07.07.08.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:51 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: revamp vmem_altmap / dev_pagemap handling
Date: Thu,  7 Dec 2017 07:08:26 -0800
Message-Id: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

Hi all,

this series started with two patches from Logan that now are in the
middle of the series to kill the memremap-internal pgmap structure
and to redo the dev_memreamp_pages interface to be better suitable
for future PCI P2P uses.  I reviewed them and noticed that there
isn't really any good reason to keep struct vmem_altmap either,
and that a lot of these alternative device page map access should
be better abstracted out instead of being sprinkled all over the
mm code.

Please review carefully, this has only been tested with my legacy
e820 NVDIMM system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
