Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A8BAA6B0083
	for <linux-mm@kvack.org>; Wed,  6 May 2009 09:39:44 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8179B82C2D9
	for <linux-mm@kvack.org>; Wed,  6 May 2009 09:52:16 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id p0v8a1-z624q for <linux-mm@kvack.org>;
	Wed,  6 May 2009 09:52:16 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CD7C282C2EE
	for <linux-mm@kvack.org>; Wed,  6 May 2009 09:52:11 -0400 (EDT)
Date: Wed, 6 May 2009 09:29:24 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 1/3] mm: SLUB fix reclaim_state
In-Reply-To: <1241594430.15411.3.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0905060928280.17580@qirst.com>
References: <20090505091343.706910164@suse.de>  <20090505091434.312182900@suse.de> <1241594430.15411.3.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: npiggin@suse.de, stable@kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Pekka Enberg wrote:

> I have applied the patch series. I see you have cc'd stable so I assume
> you want this in 2.6.30, right? This seems like a rather serious bug but
> I wonder why we've gotten away with it for so long? Is there a test
> program or a known workload that breaks without this?

You need to have a load that results in extensive slab reclaim so that the
slab pages in the reclaim path become a factor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
