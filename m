Date: Tue, 5 Feb 2008 09:24:30 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
In-Reply-To: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Mon, 4 Feb 2008, Christoph Lameter wrote:
> The statistics provided here allow the monitoring of allocator behavior
> at the cost of some (minimal) loss of performance. Counters are placed in
> SLUB's per cpu data structure that is already written to by other code.

Looks good but I am wondering if we want to make the statistics per-CPU so 
that we can see the kmalloc/kfree ping-pong of, for example, hackbench 
better?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
