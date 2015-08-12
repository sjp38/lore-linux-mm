Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B5D866B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 19:52:15 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so12366339pdr.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 16:52:15 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id a5si581801pdg.240.2015.08.12.16.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 16:52:14 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so24390745pac.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 16:52:14 -0700 (PDT)
Date: Wed, 12 Aug 2015 16:52:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/4] mm: Add support for __GFP_ZERO flag to
 dma_pool_alloc()
In-Reply-To: <1438371404-3219-2-git-send-email-sean.stalley@intel.com>
Message-ID: <alpine.DEB.2.10.1508121649310.30617@chino.kir.corp.google.com>
References: <1438371404-3219-1-git-send-email-sean.stalley@intel.com> <1438371404-3219-2-git-send-email-sean.stalley@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sean O. Stalley" <sean.stalley@intel.com>
Cc: corbet@lwn.net, vinod.koul@intel.com, bhelgaas@google.com, Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr, nicolas.palix@imag.fr, mmarek@suse.cz, akpm@linux-foundation.org, bigeasy@linutronix.de, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, dmaengine@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, cocci@systeme.lip6.fr

On Fri, 31 Jul 2015, Sean O. Stalley wrote:

> Currently the __GFP_ZERO flag is ignored by dma_pool_alloc().
> Make dma_pool_alloc() zero the memory if this flag is set.
> 
> Signed-off-by: Sean O. Stalley <sean.stalley@intel.com>

Acked-by: David Rientjes <rientjes@google.com>

This has impacted us as well, and I'm glad to see it fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
