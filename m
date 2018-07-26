Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 432076B0010
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:29:48 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c18-v6so1634642oiy.3
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:29:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a7-v6si1131313oih.311.2018.07.26.08.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 08:29:47 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QFTEQq136552
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:29:46 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kfgh8sdaq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:29:46 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 16:29:44 +0100
Date: Thu, 26 Jul 2018 18:29:38 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 7/7] docs/core-api: mm-api: add section about GFP flags
References: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1532607722-17079-8-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726130106.GC3504@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726130106.GC3504@bombadil.infradead.org>
Message-Id: <20180726152937.GG8477@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 26, 2018 at 06:01:06AM -0700, Matthew Wilcox wrote:
> On Thu, Jul 26, 2018 at 03:22:02PM +0300, Mike Rapoport wrote:
> > +Memory Allocation Controls
> > +==========================
> 
> Perhaps call this section "Memory Allocation Flags" instead?
> 
> > +Linux provides a variety of APIs for memory allocation from direct
> > +calls to page allocator through slab caches and vmalloc to allocators
> > +of compressed memory. Although these allocators have different
> > +semantics and are used in different circumstances, they all share the
> > +GFP (get free page) flags that control behavior of each allocation
> > +request.
> 
> While this isn't /wrong/, I think it might not be the most useful way
> of explaining what the GFP flags are to someone who's just come across
> them in some remote part of the kernel.  How about this paragraph instead?
> 
>   Functions which need to allocate memory often use GFP flags to express
>   how that memory should be allocated.  The GFP acronym stands for "get
>   free pages", the underlying memory allocation function.  Not every GFP
>   flag is allowed to every function which may allocate memory.  Most
>   users will want to use a plain ``GFP_KERNEL`` or ``GFP_ATOMIC``.
> 
> > +.. kernel-doc:: include/linux/gfp.h
> > +   :doc: Page mobility and placement hints
> > +
> > +.. kernel-doc:: include/linux/gfp.h
> > +   :doc: Watermark modifiers
> > +
> > +.. kernel-doc:: include/linux/gfp.h
> > +   :doc: Reclaim modifiers
> > +
> > +.. kernel-doc:: include/linux/gfp.h
> > +   :doc: Common combinations
> 
> Would it make more sense to put 'common combinations' first?

Now I feel that "common combinations" is not really good name since not all
of them are that common. The original "Useful ... combination" also does
not seem right because use of some of these combinations is discouraged.

That said, I think I'm going to change "common combinations" to "GPF flag
combinations" (as the comments cover all the defined combinations) and
leave it the last. 

-- 
Sincerely yours,
Mike.
