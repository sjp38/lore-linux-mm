Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j94GFCUd012820
	for <linux-mm@kvack.org>; Tue, 4 Oct 2005 12:15:12 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j94GFChH104350
	for <linux-mm@kvack.org>; Tue, 4 Oct 2005 12:15:12 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j94GFBMa018239
	for <linux-mm@kvack.org>; Tue, 4 Oct 2005 12:15:11 -0400
Subject: Re: sparsemem & sparsemem extreme question
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Tue, 04 Oct 2005 09:15:02 -0700
Message-Id: <1128442502.20208.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-10-04 at 08:50 +0200, Heiko Carstens wrote:
> I'm just wondering why there is all this indirection stuff here and why not
> have one contiguous aray of struct pages (residing in the vmalloc area) that
> deals with whatever size of memory an architecture wants to support.

This is exactly what ia64 does today.  Programatically, it does remove a
layer of indirection.  However, there are some data structures that have
to be traversed during a lookup: the page tables.  Granted, the TLB will
provide some caching, but a lookup on ia64 can potentially be much more
expensive than the two cacheline misses that sparsemem extreme might
have.

In the end no one has ever produced any compelling performance reason to
use a vmem_map (as ia64 calls it).  In addition, sparsemem doesn't cause
any known performance regressions, either.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
