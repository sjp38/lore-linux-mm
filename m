Date: Mon, 9 Oct 2006 11:12:03 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] memory page_alloc zonelist caching speedup
Message-Id: <20061009111203.5dba9cbe.akpm@osdl.org>
In-Reply-To: <20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
	<20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Andi Kleen <ak@suse.de>, mbligh@google.com, rohitseth@google.com, menage@google.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 09 Oct 2006 03:54:57 -0700
Paul Jackson <pj@sgi.com> wrote:

> Optimize the critical zonelist scanning for free pages in the kernel
> memory allocator by caching the zones that were found to be full
> recently, and skipping them.

This doesn't exactly simplify the kernel, but the benchmark numbers
are nice.

I worry about the one-second-expiry thing.  Wall time is a pretty
meaningless thing in the context of the page allocator and it doesn't seem
appropriate to use it.  A more appropriate measure of "time" in this
context would be number-of-pages-allocated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
