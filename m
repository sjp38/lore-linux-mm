Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD5C6B0269
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 19:32:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w1-v6so2859037plq.8
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 16:32:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k23-v6si8258366pfi.177.2018.06.15.16.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 16:32:41 -0700 (PDT)
Date: Fri, 15 Jun 2018 16:32:40 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH] mm/memblock: add missing include <linux/bootmem.h>
Message-ID: <20180615233236.GA17678@agluck-desk>
References: <20180606194144.16990-1-malat@debian.org>
 <CA+8MBbKj4A5kh=hE0vcadzD+=cEAFY7OCWFCzvubu6cWULCJ0A@mail.gmail.com>
 <20180615121716.37fb93385825b0b2f59240cc@linux-foundation.org>
 <CA+8MBbJyXC7YmnjG-k+mahC0ZiSgZy=EoiO0N5gvw8S4afLqng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+8MBbJyXC7YmnjG-k+mahC0ZiSgZy=EoiO0N5gvw8S4afLqng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathieu Malaterre <malat@debian.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

This both compiles and boots on ia64.

Builds OK on x86_64 with an Enterprise OS .config that includes:
CONFIG_HAVE_MEMBLOCK=y
CONFIG_NO_BOOTMEM=y

-Tony

----

diff --git a/mm/memblock.c b/mm/memblock.c
index cc16d70b8333..0a54d488f767 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1225,6 +1225,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
+#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
 /**
  * memblock_virt_alloc_internal - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
@@ -1432,6 +1433,7 @@ void * __init memblock_virt_alloc_try_nid(
 	      (u64)max_addr);
 	return NULL;
 }
+#endif
 
 /**
  * __memblock_free_early - free boot memory block
