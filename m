Date: Tue, 5 Feb 2008 09:54:51 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
In-Reply-To: <47A81513.4010301@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0802050952300.16488@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI> <47A81513.4010301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Eric Dumazet wrote:
> > Looks good but I am wondering if we want to make the statistics per-CPU so
> > that we can see the kmalloc/kfree ping-pong of, for example, hackbench
> > better?
> 
> AFAIK Christoph patch already have percpu statistics :)

Heh, sure, but it's not exported to userspace which is required for 
slabinfo to display the statistics.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
