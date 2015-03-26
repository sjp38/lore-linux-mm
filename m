Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 203206B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 03:28:03 -0400 (EDT)
Received: by wibg7 with SMTP id g7so9884876wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 00:28:02 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c1si9133026wie.19.2015.03.26.00.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 00:28:01 -0700 (PDT)
Date: Thu, 26 Mar 2015 08:28:00 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [patch 1/4] fs, jfs: remove slab object constructor
Message-ID: <20150326072800.GA26163@lst.de>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com> <alpine.LRH.2.02.1503252157330.6657@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1503251935180.16714@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503251935180.16714@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net

On Wed, Mar 25, 2015 at 07:37:40PM -0700, David Rientjes wrote:
> That would be true only for
> 
> 	ptr = mempool_alloc(gfp, pool);
> 	mempool_free(ptr, pool);
> 
> and nothing in between, and that's pretty pointless.  Typically, callers 
> allocate memory, modify it, and then free it.  When that happens with 
> mempools, and we can't allocate slab because of the gfp context, mempools 
> will return elements in the state in which they were freed (modified, not 
> as constructed).

The historic slab allocator (Solaris and early Linux) expects objects
to be returned in the same / similar enough form as the constructor
returned it, and the constructor is only called when allocating pages
from the page pool.

I have to admit that I haven't used this feature forever, and I have no idea if
people changed how the allocator works in the meantime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
