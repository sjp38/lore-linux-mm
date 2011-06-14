Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A731F6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 16:40:20 -0400 (EDT)
Date: Tue, 14 Jun 2011 15:40:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slob: push the min alignment to long long
In-Reply-To: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
Message-ID: <alpine.DEB.2.00.1106141538560.1613@router.home>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org

On Tue, 14 Jun 2011, Sebastian Andrzej Siewior wrote:

> Therefore I'm changing the default alignment of SLOB to 8. This fixes my
> netfilter problems (and probably other) and we have consistent behavior
> across all SL*B allocators.

If you do that then all slab allocators do the same and we may move
that alignment stuff into include/linux/slab.h instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
