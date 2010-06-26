Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABDF6B01AD
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 22:24:49 -0400 (EDT)
Date: Sat, 26 Jun 2010 12:24:42 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
Message-ID: <20100626022441.GC29809@laptop>
References: <20100625212026.810557229@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100625212026.810557229@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 25, 2010 at 04:20:26PM -0500, Christoph Lameter wrote:
> The following patchset cleans some pieces up and then equips SLUB with
> per cpu queues that work similar to SLABs queues. With that approach
> SLUB wins in hackbench:

Hackbench I don't think is that interesting. SLQB was beating SLAB
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
