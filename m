Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F35976B000E
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:15:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o7-v6so6054411pgc.23
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 23:15:14 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id x69-v6si16104196pfa.108.2018.06.18.23.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 23:15:13 -0700 (PDT)
Subject: [PATCH v3 7/8] mm, hmm: Mark hmm_devmem_{add,
 add_resource} EXPORT_SYMBOL_GPL
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Jun 2018 23:05:15 -0700
Message-ID: <152938831573.17797.15264540938029137916.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The routines hmm_devmem_add(), and hmm_devmem_add_resource() are
now wrappers around the functionality provided by devm_memremap_pages() to
inject a dev_pagemap instance and hook page-idle events. The
devm_memremap_pages() interface is base infrastructure for HMM which has
more and deeper ties into the kernel memory management implementation
than base ZONE_DEVICE.

Originally, the HMM page structure creation routines copied the
devm_memremap_pages() code and reused ZONE_DEVICE. A cleanup to unify
the implementations was discussed during the initial review:
http://lkml.iu.edu/hypermail/linux/kernel/1701.2/00812.html

Given that devm_memremap_pages() is marked EXPORT_SYMBOL_GPL by its
authors and the hmm_devmem_{add,add_resource} routines are simple
wrappers around that base, mark these routines as EXPORT_SYMBOL_GPL as
well.

Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/hmm.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index b019d67a610e..481a7a5f6f46 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1054,7 +1054,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 		return result;
 	return devmem;
 }
-EXPORT_SYMBOL(hmm_devmem_add);
+EXPORT_SYMBOL_GPL(hmm_devmem_add);
 
 struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 					   struct device *device,
@@ -1108,7 +1108,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 		return result;
 	return devmem;
 }
-EXPORT_SYMBOL(hmm_devmem_add_resource);
+EXPORT_SYMBOL_GPL(hmm_devmem_add_resource);
 
 /*
  * A device driver that wants to handle multiple devices memory through a
