MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16881.33367.660452.55933@cargo.ozlabs.ibm.com>
Date: Sat, 22 Jan 2005 09:29:43 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: Extend clear_page by an order parameter
In-Reply-To: <Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
	<20050108135636.6796419a.davem@davemloft.net>
	<Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "David S. Miller" <davem@davemloft.net>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter writes:

> The zeroing of a page of a arbitrary order in page_alloc.c and in hugetlb.c may benefit from a
> clear_page that is capable of zeroing multiple pages at once (and scrubd
> too but that is now an independent patch). The following patch extends
> clear_page with a second parameter specifying the order of the page to be zeroed to allow an
> efficient zeroing of pages. Hope I caught everything....

Wouldn't it be nicer to call the version that takes the order
parameter "clear_pages" and then define clear_page(p) as
clear_pages(p, 0) ?

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
