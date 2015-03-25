Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 499036B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:55:25 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so41354163pdb.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 14:55:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k6si5439663pdp.70.2015.03.25.14.55.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 14:55:24 -0700 (PDT)
Date: Wed, 25 Mar 2015 14:55:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2 4/4] mm, mempool: poison elements backed by page
 allocator
Message-Id: <20150325145523.94d1033b93cd5c1010df93bf@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, Andrey Ryabinin <a.ryabinin@samsung.com>

On Tue, 24 Mar 2015 16:10:01 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> Elements backed by the slab allocator are poisoned when added to a
> mempool's reserved pool.
> 
> It is also possible to poison elements backed by the page allocator
> because the mempool layer knows the allocation order.
> 
> This patch extends mempool element poisoning to include memory backed by
> the page allocator.
> 
> This is only effective for configs with CONFIG_DEBUG_SLAB or
> CONFIG_SLUB_DEBUG_ON.
> 

Maybe mempools should get KASAN treatment (as well as this)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
