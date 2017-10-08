Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CCE1E6B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 05:16:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e26so34464673pfd.4
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 02:16:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f35si4533710plh.346.2017.10.08.02.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Oct 2017 02:16:55 -0700 (PDT)
Date: Sun, 8 Oct 2017 02:16:54 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vmalloc: add __alloc_vm_area() for optimizing vmap stack
Message-ID: <20171008091654.GA29939@infradead.org>
References: <150728974697.743944.5376694940133890044.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150728974697.743944.5376694940133890044.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>

This looks fine in general, but a few comments:

 - can you split adding the new function from switching over the fork
   code?
 - at least kasan and vmalloc_user/vmalloc_32_user use very similar
   patterns, can you switch them over as well?
 - the new __alloc_vm_area looks very different from alloc_vm_area,
   maybe it needs a better name?  vmalloc_range_area for example?
 - when you split an existing function please keep the more low-level
   function on top of the higher level one that calls it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
