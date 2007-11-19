Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJI7I6W016061
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 13:07:18 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAJI7F7W1278122
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 13:07:15 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJI7Bqb007184
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 11:07:12 -0700
Subject: Re: [RFC 5/7] LTTng instrumentation mm
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071116144742.GA17255@Krystal>
References: <20071113193349.214098508@polymtl.ca>
	 <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost>
	 <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost>
	 <20071116144742.GA17255@Krystal>
Content-Type: text/plain
Date: Mon, 19 Nov 2007 10:07:05 -0800
Message-Id: <1195495626.27759.119.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-16 at 09:47 -0500, Mathieu Desnoyers wrote:
> * Dave Hansen (haveblue@us.ibm.com) wrote:
> > For most (all?) architectures, the PFN and the virtual address in the
> > kernel's linear are interchangeable with pretty trivial arithmetic.  All
> > pages have a pfn, but not all have a virtual address.  Thus, I suggested
> > using the pfn.  What kind of virtual addresses are you talking about?
> > 
> 
> Hrm, in asm-generic/memory_model.h, we have various versions of
> __page_to_pfn. Normally they all cast the result to (unsigned long),
> except for :
> 
> 
> #elif defined(CONFIG_SPARSEMEM_VMEMMAP)
> 
> /* memmap is virtually contigious.  */
> #define __pfn_to_page(pfn)      (vmemmap + (pfn))
> #define __page_to_pfn(page)     ((page) - vmemmap)
> 
> So I guess the result is a pointer ? Should this be expected ?

Nope.  'pointer - pointer' is an integer.  Just solve this equation for
integer:

	'pointer + integer = pointer'

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
