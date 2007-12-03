Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id lB32KW7l017760
	for <linux-mm@kvack.org>; Mon, 3 Dec 2007 13:20:32 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB32KjEZ2736378
	for <linux-mm@kvack.org>; Mon, 3 Dec 2007 13:20:46 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB32Kjkr019004
	for <linux-mm@kvack.org>; Mon, 3 Dec 2007 13:20:45 +1100
Date: Mon, 3 Dec 2007 13:06:48 +1100
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH 2/2] powerpc: make 64K huge pages more reliable
Message-ID: <20071203020648.GF26919@localhost.localdomain>
References: <474CF694.8040700@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <474CF694.8040700@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kniht@linux.vnet.ibm.com
Cc: linuxppc-dev <linuxppc-dev@ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 27, 2007 at 11:03:16PM -0600, Jon Tollefson wrote:
> This patch adds reliability to the 64K huge page option by making use of 
> the PMD for 64K huge pages when base pages are 4k.  So instead of a 12 
> bit pte it would be 7 bit pmd and a 5 bit pte. The pgd and pud offsets 
> would continue as 9 bits and 7 bits respectively.  This will allow the 
> pgtable to fit in one base page.  This patch would have to be applied 
> after part 1.

Hrm.. shouldn't we just ban 64K hugepages on a 64K base page size
setup?  There's not a whole lot of point to it, after all...

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
