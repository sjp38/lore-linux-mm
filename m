Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0889C6B000A
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:45:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e1-v6so9351810pld.23
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:45:39 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id f3-v6si15343939plf.436.2018.05.21.15.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 15:45:37 -0700 (PDT)
Subject: [PATCH 5/5] mm, hmm: mark hmm_devmem_{add,
 add_resource} EXPORT_SYMBOL_GPL
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 21 May 2018 15:35:40 -0700
Message-ID: <152694214044.5484.1081005408496303826.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The routines hmm_devmem_add(), and hmm_devmem_add_resource() are small
wrappers around devm_memremap_pages(). The devm_memremap_pages()
interface is a subset of the hmm functionality which has more and deeper
ties into the kernel memory management implementation. It was an
oversight that these symbols were not marked EXPORT_SYMBOL_GPL from the
outset due to how they originally copied (and now reuse)
devm_memremap_pages().

Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/hmm.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index a4162406067c..d9aef1266ed6 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1072,7 +1072,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 
 	return devmem;
 }
-EXPORT_SYMBOL(hmm_devmem_add);
+EXPORT_SYMBOL_GPL(hmm_devmem_add);
 
 struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 					   struct device *device,
@@ -1131,7 +1131,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 
 	return devmem;
 }
-EXPORT_SYMBOL(hmm_devmem_add_resource);
+EXPORT_SYMBOL_GPL(hmm_devmem_add_resource);
 
 /*
  * A device driver that wants to handle multiple devices memory through a
