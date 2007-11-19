Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJI50BK017055
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 13:05:00 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAJI4m7f078650
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 11:04:51 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJI4l7f021908
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 11:04:48 -0700
Subject: Re: [RFC 5/7] LTTng instrumentation mm
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071116143019.GA16082@Krystal>
References: <20071113193349.214098508@polymtl.ca>
	 <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost>
	 <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost>
	 <20071116143019.GA16082@Krystal>
Content-Type: text/plain
Date: Mon, 19 Nov 2007 10:04:45 -0800
Message-Id: <1195495485.27759.115.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-16 at 09:30 -0500, Mathieu Desnoyers wrote:
> I see that the standard macro to get the kernel address from a pfn is :
> 
> asm-x86/page_32.h:#define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
> 
> The question might seem trivial, but I wonder how this deals with large
> pages ?

Well, first of all, large pages are a virtual addressing concept.  We're
only talking about physical addresses here.  You still address the
memory the same way no matter if it is composed of large or small pages.
The physical address (and pfn) never change no matter what we do with
the page or how we allocate ir.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
