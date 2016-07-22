Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80CC56B025F
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 01:50:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y134so210916315pfg.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 22:50:45 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id d5si14014398pfb.98.2016.07.21.22.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 22:50:44 -0700 (PDT)
In-Reply-To: <20160405190547.GA12673@us.ibm.com>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [1/1] powerpc/mm: Add memory barrier in __hugepte_alloc()
Message-Id: <3rwfrd6Vq2z9sxb@ozlabs.org>
Date: Fri, 22 Jul 2016 15:50:41 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, James Dykman <jdykman@us.ibm.com>

On Tue, 2016-05-04 at 19:05:47 UTC, Sukadev Bhattiprolu wrote:
> >From f7b73c6b4508fe9b141a43d92be2f9dd7d3c4a58 Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> Date: Thu, 24 Mar 2016 02:07:57 -0400
> Subject: [PATCH 1/1] powerpc/mm: Add memory barrier in __hugepte_alloc()
> 
> __hugepte_alloc() uses kmem_cache_zalloc() to allocate a zeroed PTE
> and proceeds to use the newly allocated PTE. Add a memory barrier to
> make sure that the other CPUs see a properly initialized PTE.
> 
> Based on a fix suggested by James Dykman.
> 
> Reported-by: James Dykman <jdykman@us.ibm.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> Tested-by: James Dykman <jdykman@us.ibm.com>

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/0eab46be21449f1612791201aa

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
