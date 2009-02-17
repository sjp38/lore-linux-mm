Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EE8806B0092
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 10:51:19 -0500 (EST)
Subject: Re: [patch 1/8] slab: introduce kzfree()
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <alpine.DEB.1.10.0902171007010.19685@qirst.com>
References: <20090216142926.440561506@cmpxchg.org>
	 <20090216144725.572446535@cmpxchg.org> <20090216152751.GA27520@cmpxchg.org>
	 <alpine.DEB.1.10.0902171007010.19685@qirst.com>
Date: Tue, 17 Feb 2009 17:51:16 +0200
Message-Id: <1234885876.11511.3.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-02-17 at 10:08 -0500, Christoph Lameter wrote:
> Why would you want to zero an object on release? Is this for security?
> 
> Please give us some rationale for this. Do we need free on zero now for
> all allocators?

All the call-sites zero out before kfree() for security reasons. But
yeah, we should put that in the patch description as well.

Johannes, I suppose it would make sense to resend the series to Andrew
with all the updates?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
