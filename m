Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2A456B0007
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:22:48 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id z14so4127758wrh.1
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:22:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r29si15566124wra.288.2018.03.08.15.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 15:22:47 -0800 (PST)
Date: Thu, 8 Mar 2018 15:22:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Message-Id: <20180308152244.2ba75bc2a766541ab8330eb0@linux-foundation.org>
In-Reply-To: <20180308222201.GB29073@bombadil.infradead.org>
References: <20180308130523.GA30642@jordon-HP-15-Notebook-PC>
	<20180308222201.GB29073@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

On Thu, 8 Mar 2018 14:22:01 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> On Thu, Mar 08, 2018 at 06:35:23PM +0530, Souptick Joarder wrote:
> > Use new return type vm_fault_t for fault handler
> > in struct vm_operations_struct.
> > 
> > vmf_insert_mixed(), vmf_insert_pfn() and vmf_insert_page()
> > are newly added inline wrapper functions.
> > 
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> 
> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Andrew, the plan for these patches is to introduce the typedef, initially
> just as documentation ("This function should return a VM_FAULT_ status").
> We'll trickle the patches to individual drivers/filesystems in through
> the maintainers, as far as possible.  In a few months, we'll probably
> dump a pile of patches to unloved drivers on you for merging.  Then we'll
> change the typedef to an unsigned int and break the compilation of any
> unconverted driver.
> 
> Souptick has done a few dozen drivers already, and I've been doing my best
> to keep up with reviewing the patches submitted.  There's some interesting
> patterns and commonalities between drivers (not to mention a few outright
> bugs) that we've noticed, and this'll be a good time to clean them up.

OK.  All of this should be in the changelog, please.  Along with a full
explanation of the reasons for adding the new functions.

> It'd be great to get this into Linus' tree sooner so we can start
> submitting the patches to the driver maintainers.

Sure.  I assume that vm_fault_t is `int', so this bare patch won't
cause a ton of type mismatch warnings?
