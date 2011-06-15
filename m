Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F33D6B0082
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:24:30 -0400 (EDT)
Subject: Re: [PATCH] slob: push the min alignment to long long
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20110615201202.GB19593@Chamillionaire.breakpoint.cc>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
	 <1308089140.15617.221.camel@calx>
	 <20110615201202.GB19593@Chamillionaire.breakpoint.cc>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Jun 2011 15:24:26 -0500
Message-ID: <1308169466.15617.378.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org

On Wed, 2011-06-15 at 22:12 +0200, Sebastian Andrzej Siewior wrote:
> * Matt Mackall | 2011-06-14 17:05:40 [-0500]:
> 
> >Ok, so you claim that ARCH_KMALLOC_MINALIGN is not set on some
> >architectures, and thus SLOB does the wrong thing.
> >
> >Doesn't that rather obviously mean that the affected architectures
> >should define ARCH_KMALLOC_MINALIGN? Because, well, they have an
> >"architecture-specific minimum kmalloc alignment"?
> 
> nope, if nothing is defined SLOB asumes that alignment of long is the way
> go. Unfortunately alignment of u64 maybe larger than of u32.

I understand that. I guess we have a different idea of what constitutes
"architecture-specific" and what constitutes "normal".

But I guess I can be persuaded that most architectures now expect 64-bit
alignment of u64s.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
