MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16881.42871.346498.568098@cargo.ozlabs.ibm.com>
Date: Sat, 22 Jan 2005 12:08:07 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: Extend clear_page by an order parameter
In-Reply-To: <20050121164353.6f205fbc.akpm@osdl.org>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
	<20050108135636.6796419a.davem@davemloft.net>
	<Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
	<16881.33367.660452.55933@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0501211545080.27045@schroedinger.engr.sgi.com>
	<16881.40893.35593.458777@cargo.ozlabs.ibm.com>
	<20050121164353.6f205fbc.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, davem@davemloft.net, hugh@veritas.com, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:

> It is, actually, from the POV of the page allocator.  It's a "higher order
> page" and is controlled by a struct page*, just like a zero-order page...

OK.  I still reckon it's confusing terminology for the rest of us who
don't have our heads deep in the page allocator code.

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
