Date: Fri, 8 Feb 2008 11:19:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 2/2] Explicitly retry hugepage allocations
In-Reply-To: <20080208171132.GE15903@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0802081117340.1654@schroedinger.engr.sgi.com>
References: <20080206230726.GF3477@us.ibm.com> <20080206231243.GG3477@us.ibm.com>
 <Pine.LNX.4.64.0802061529480.22648@schroedinger.engr.sgi.com>
 <20080208171132.GE15903@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: melgor@ie.ibm.com, apw@shadowen.org, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2008, Nishanth Aravamudan wrote:

> I also am not 100% positive on how I would test the result of such a
> change, since there are not that many large-order allocations in the
> kernel... Did you have any thoughts on that?

Boot the kernel with

	slub_min_order=<whatever order you wish>

to get lots of allocations of a higher order.

You can run slub with huge pages by booting with

	slub_min_order=9

this causes some benchmarks to run much faster...

In general the use of higher order pages is discouraged right now due 
to the page allocators flaky behavior when allocating pages but 
there are several projects that would benefit from that. Amoung them large 
bufferer support for the I/O layer and larger page support for the VM to 
reduce 4k page scanning overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
