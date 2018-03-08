Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E36F6B0007
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 17:22:03 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id az5-v6so3415057plb.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 14:22:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s11si13632233pgf.196.2018.03.08.14.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Mar 2018 14:22:02 -0800 (PST)
Date: Thu, 8 Mar 2018 14:22:01 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Message-ID: <20180308222201.GB29073@bombadil.infradead.org>
References: <20180308130523.GA30642@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180308130523.GA30642@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Mar 08, 2018 at 06:35:23PM +0530, Souptick Joarder wrote:
> Use new return type vm_fault_t for fault handler
> in struct vm_operations_struct.
> 
> vmf_insert_mixed(), vmf_insert_pfn() and vmf_insert_page()
> are newly added inline wrapper functions.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

Andrew, the plan for these patches is to introduce the typedef, initially
just as documentation ("This function should return a VM_FAULT_ status").
We'll trickle the patches to individual drivers/filesystems in through
the maintainers, as far as possible.  In a few months, we'll probably
dump a pile of patches to unloved drivers on you for merging.  Then we'll
change the typedef to an unsigned int and break the compilation of any
unconverted driver.

Souptick has done a few dozen drivers already, and I've been doing my best
to keep up with reviewing the patches submitted.  There's some interesting
patterns and commonalities between drivers (not to mention a few outright
bugs) that we've noticed, and this'll be a good time to clean them up.

It'd be great to get this into Linus' tree sooner so we can start
submitting the patches to the driver maintainers.
