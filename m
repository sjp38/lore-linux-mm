Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAFL6d5g024775
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 16:06:39 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAFL6Qh5065682
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 16:06:39 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAFL6PQl016184
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 16:06:25 -0500
Subject: Re: [RFC 5/7] LTTng instrumentation mm
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071113194025.150641834@polymtl.ca>
References: <20071113193349.214098508@polymtl.ca>
	 <20071113194025.150641834@polymtl.ca>
Content-Type: text/plain
Date: Thu, 15 Nov 2007 13:06:23 -0800
Message-Id: <1195160783.7078.203.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 2007-11-13 at 14:33 -0500, Mathieu Desnoyers wrote:
>  linux-2.6-lttng/mm/page_io.c        2007-11-13 09:49:35.000000000 -0500
> @@ -114,6 +114,7 @@ int swap_writepage(struct page *page, st
>                 rw |= (1 << BIO_RW_SYNC);
>         count_vm_event(PSWPOUT);
>         set_page_writeback(page);
> +       trace_mark(mm_swap_out, "address %p", page_address(page));
>         unlock_page(page);
>         submit_bio(rw, bio);
>  out:

I'm not sure all this page_address() stuff makes any sense on highmem
systems.  How about page_to_pfn()?

I also have to wonder if you should be hooking into count_vm_event() and
using those.  Could you give a high-level overview of exactly why you
need these hooks, and perhaps what you expect from future people adding
things to the VM?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
