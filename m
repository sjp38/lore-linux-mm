Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05D316B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 03:02:29 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s38so94429123ioi.9
        for <linux-mm@kvack.org>; Tue, 23 May 2017 00:02:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f15si20617942pln.274.2017.05.23.00.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 00:02:28 -0700 (PDT)
Date: Tue, 23 May 2017 00:02:27 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
Message-ID: <20170523070227.GA27864@infradead.org>
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
 <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 22, 2017 at 02:11:49PM -0700, Andrew Morton wrote:
> On Mon, 22 May 2017 16:47:42 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
> 
> > There are many places where we define size either left shifting integers
> > or multiplying 1024s without any generic definition to fall back on. But
> > there are couples of (powerpc and lz4) attempts to define these standard
> > memory sizes. Lets move these definitions to core VM to make sure that
> > all new usage come from these definitions eventually standardizing it
> > across all places.
> 
> Grep further - there are many more definitions and some may now
> generate warnings.
> 
> Newly including mm.h for these things seems a bit heavyweight.  I can't
> immediately think of a more appropriate place.  Maybe printk.h or
> kernel.h.

IFF we do these kernel.h is the right place.  And please also add the
MiB & co variants for the binary versions right next to the decimal
ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
