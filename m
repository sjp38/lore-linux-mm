Date: Fri, 23 Mar 2007 22:21:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
Message-Id: <20070323222133.f17090cf.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703231026490.23132@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
	<20070322223927.bb4caf43.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
	<20070322234848.100abb3d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0703231026490.23132@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2007 10:54:12 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> Here are the results of aim9 tests on x86_64. There are some minor performance 
> improvements and some fluctuations.

There are a lot of numbers there - what do they tell us?

> 2.6.21-rc4 bare
> 2.6.21-rc4 x86_64 quicklist

So what has changed here?  From a quick look it appears that x86_64 is
using get_zeroed_page() for ptes, puds and pmds and is using a custom
quicklist for pgds.

After your patches, x86_64 is using a common quicklist allocator for puds,
pmds and pgds and continues to use get_zeroed_page() for ptes.

Or something totally different, dunno.  I tire.


My question is pretty simple: how do we justify the retention of this
custom allocator?

Because simply removing it is the preferable way of fixing the SLUB
problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
