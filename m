Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3064C6B007E
	for <linux-mm@kvack.org>; Sat, 26 Mar 2016 05:47:24 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id tt10so62324520pab.3
        for <linux-mm@kvack.org>; Sat, 26 Mar 2016 02:47:24 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 5si25967523pfi.35.2016.03.26.02.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Mar 2016 02:47:23 -0700 (PDT)
In-Reply-To: <1458921929-15264-1-git-send-email-gwshan@linux.vnet.ibm.com>
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [RFC] mm: Fix memory corruption caused by deferred page initialization
Message-Id: <3qXFh60DRNz9sDH@ozlabs.org>
Date: Sat, 26 Mar 2016 20:47:17 +1100 (AEDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, mgorman@suse.de, zhlcindy@linux.vnet.ibm.com

Hi Gavin,

On Fri, 2016-25-03 at 16:05:29 UTC, Gavin Shan wrote:
> During deferred page initialization, the pages are moved from memblock
> or bootmem to buddy allocator without checking they were reserved. Those
> reserved pages can be reallocated to somebody else by buddy/slab allocator.
> It leads to memory corruption and potential kernel crash eventually.

Can you give me a bit more detail on what the bug is?

I haven't seen any issues on my systems, but I realise now I haven't enabled
DEFERRED_STRUCT_PAGE_INIT - I assumed it was enabled by default.

How did this get tested before submission?

> This fixes above issue by:
> 
>    * Deferred releasing bootmem bitmap until the completion of deferred
>      page initialization.

As I said in my other mail, we don't support bootmem anymore. So please resend
with just the non-bootmem fixes.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
