Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0P4EHZW001656
	for <linux-mm@kvack.org>; Tue, 24 Jan 2006 23:14:17 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0P4EHG4148832
	for <linux-mm@kvack.org>; Tue, 24 Jan 2006 23:14:17 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0P4EHP7014412
	for <linux-mm@kvack.org>; Tue, 24 Jan 2006 23:14:17 -0500
Message-ID: <43D6FB12.9080805@us.ibm.com>
Date: Tue, 24 Jan 2006 22:14:10 -0600
From: Brian Twichell <tbrian@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] Shared page tables
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <43C73767.5060506@us.ibm.com>
In-Reply-To: <43C73767.5060506@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickens <hugh@veritas.com>, slpratt@us.ibm.com
List-ID: <linux-mm.kvack.org>

Brian Twichell wrote:

>
> We evaluated page table sharing on x86_64 and ppc64 setups, using a 
> database
> OLTP workload.  In both cases, 4-way systems with 64 GB of memory were 
> used.
>
> On the x86_64 setup, page table sharing provided a 25% increase in 
> performance,
> when the database buffers were in small (4 KB) pages.  In this case, 
> over 14 GB
> of memory was freed, that had previously been taken up by page 
> tables.  In the
> case that the database buffers were in huge (2 MB) pages, page table 
> sharing
> provided a 4% increase in performance.
>
> Our ppc64 experiments used an earlier version of Dave's patch, along with
> ppc64-specific code for sharing of ppc64 segments.  On this setup, page
> table sharing provided a 49% increase in performance, when the database
> buffers were in small (4 KB) pages.  Over 10 GB of memory was freed, that
> had previously been taken up by page tables.  In the case that the 
> database
> buffers were in huge (16 MB) pages, page table sharing provided a 3% 
> increase
> in performance.
>
Hi,

Just wanted to dispel any notion that may be out there that
the improvements we've seen are peculiar to an IBM product
stack.

The 49% improvement observed using small pages on ppc64 used
Oracle as the DBMS.  The other results used DB2 as the DBMS.

So, the improvements not peculiar to an IBM product stack,
and moreover the largest improvement was seen with a non-IBM
DBMS.

Note, the relative improvement observed on each platform/pagesize
combination cannot be used to infer relative performance between
DBMS's or platforms.

Cheers,
Brian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
