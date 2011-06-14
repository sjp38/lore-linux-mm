Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7459E6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 18:05:49 -0400 (EDT)
Subject: Re: [PATCH] slob: push the min alignment to long long
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 14 Jun 2011 17:05:40 -0500
Message-ID: <1308089140.15617.221.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org

On Tue, 2011-06-14 at 22:10 +0200, Sebastian Andrzej Siewior wrote:
> In SLOB ARCH_KMALLOC_MINALIGN is 4 on 32bit platforms by default. On
> powerpc and some other architectures except x86 the default alignment of
> u64 is 8. The leads to __alignof__(struct ipt_entry) being 8 instead of 4
> which is enforced by SLOB.

Ok, so you claim that ARCH_KMALLOC_MINALIGN is not set on some
architectures, and thus SLOB does the wrong thing.

Doesn't that rather obviously mean that the affected architectures
should define ARCH_KMALLOC_MINALIGN? Because, well, they have an
"architecture-specific minimum kmalloc alignment"?

This change will regress SLOB everywhere where '4' was the right answer.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
