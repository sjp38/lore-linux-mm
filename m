Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7UEuqqT012890
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 10:56:52 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7UEuoEd075372
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 08:56:52 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7UEunuT026139
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 08:56:49 -0600
Subject: Re: [RFC][PATCH 10/10] convert the "easy" architectures to generic
	PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060830100518.GA10629@localhost.internal.ocgnet.org>
References: <20060829201934.47E63D1F@localhost.localdomain>
	 <20060829201941.38D6254C@localhost.localdomain>
	 <20060830100518.GA10629@localhost.internal.ocgnet.org>
Content-Type: text/plain
Date: Wed, 30 Aug 2006 07:56:41 -0700
Message-Id: <1156949801.12898.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, rdunlap@xenotime.net
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-30 at 05:05 -0500, Paul Mundt wrote:
> 
> > -/* PAGE_SHIFT determines the page size */
> > -#define PAGE_SHIFT   12
> > -#define PAGE_SIZE    (1UL << PAGE_SHIFT)
> > -#define PAGE_MASK    (~(PAGE_SIZE-1))
> > -#define PTE_MASK     PAGE_MASK
> > +#include <asm-generic/page.h>
> >  
> Overzealous deletion? Please leave PTE_MASK there, we use it for
> _PAGE_CHG_MASK in pgtable.h.

Yes.  I'll fix that up.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
