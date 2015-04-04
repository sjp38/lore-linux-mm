Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 271476B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 22:06:35 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so16834391igb.1
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 19:06:34 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id qe2si3133237igb.46.2015.04.03.19.06.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Apr 2015 19:06:34 -0700 (PDT)
Received: by iebmp1 with SMTP id mp1so93927445ieb.0
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 19:06:34 -0700 (PDT)
Date: Fri, 3 Apr 2015 19:06:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, mempool: kasan: poison mempool elements
In-Reply-To: <1428072467-21668-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.10.1504031906170.8970@chino.kir.corp.google.com>
References: <1428072467-21668-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, Dmitry Chernenkov <drcheren@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

On Fri, 3 Apr 2015, Andrey Ryabinin wrote:

> Mempools keep allocated objects in reserved for situations
> when ordinary allocation may not be possible to satisfy.
> These objects shouldn't be accessed before they leave
> the pool.
> This patch poison elements when get into the pool
> and unpoison when they leave it. This will let KASan
> to detect use-after-free of mempool's elements.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Tested-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
