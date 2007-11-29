Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lATMEjLU010677
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 17:14:45 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lATMEj1m461350
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 17:14:45 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lATMEjUA032420
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 17:14:45 -0500
Subject: Re: [PATCH] mm: fix confusing __GFP_REPEAT related comments
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071129214828.GD20882@us.ibm.com>
References: <20071129214828.GD20882@us.ibm.com>
Content-Type: text/plain
Date: Thu, 29 Nov 2007 15:14:40 -0800
Message-Id: <1196378080.18851.116.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, mel@skynet.ie, wli@holomorphy.com, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-29 at 13:48 -0800, Nishanth Aravamudan wrote:
> __GFP_NOFAIL means repeat forever
> 
> order <= PAGE_ALLOC_COSTLY_ORDER means __GFP_NOFAIL 

If this is true, why do we still pass in __GFP_REPEAT to the pgd_alloc()
functions (at least in x86's pgalloc_64.h and pgtable_32.c).  We don''t
ever have pagetables exceeding PAGE_ALLOC_COSTLY_ORDER, do we?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
