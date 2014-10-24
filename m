Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 77E046B0089
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 23:55:17 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so718188pdi.2
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 20:55:17 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id jb5si3235207pbd.44.2014.10.23.20.55.15
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 20:55:16 -0700 (PDT)
Date: Thu, 23 Oct 2014 23:55:11 -0400 (EDT)
Message-Id: <20141023.235511.1672975903756808524.davem@davemloft.net>
Subject: Re: [PATCH V2 1/2] mm: Update generic gup implementation to handle
 hugepage directory
From: David Miller <davem@davemloft.net>
In-Reply-To: <1414107635.364.91.camel@pasglop>
References: <20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
	<20141023.184035.388557314666522484.davem@davemloft.net>
	<1414107635.364.91.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org
Cc: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, steve.capper@linaro.org, aarcange@redhat.com, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, hannes@cmpxchg.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 24 Oct 2014 10:40:35 +1100

> Another option would be to make the generic code use something defined
> by the arch to decide whether to use speculative get or
> not. I like the idea of keeping the bulk of that code generic...

Me too.  We could have inlines that do either speculative or
non-speculative gets on the pages in some header file and hide
the ifdefs in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
