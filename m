Date: Tue, 27 Mar 2007 04:19:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
Message-ID: <20070327111943.GC2986@holomorphy.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com> <20070322223927.bb4caf43.akpm@linux-foundation.org> <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com> <20070322234848.100abb3d.akpm@linux-foundation.org> <Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0703231026490.23132@schroedinger.engr.sgi.com> <20070323222133.f17090cf.akpm@linux-foundation.org> <Pine.LNX.4.64.0703260938520.3297@schroedinger.engr.sgi.com> <20070326102651.6d59207b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070326102651.6d59207b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 26, 2007 at 10:26:51AM -0800, Andrew Morton wrote:
> b) we understand why the below simple modification crashes i386.

This doesn't crash i386 in qemu here on a port of the quicklist patches
to 2.6.21-rc5-mm2. I suppose I'll have to dump it on some real hardware
to see if I can reproduce it there.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
