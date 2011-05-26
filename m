Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 695026B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:12:11 -0400 (EDT)
Message-ID: <4DDE9670.3060709@zytor.com>
Date: Thu, 26 May 2011 11:05:36 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
References: <20110516202605.274023469@linux.com> <20110516202625.197639928@linux.com>
In-Reply-To: <20110516202625.197639928@linux.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 05/16/2011 01:26 PM, Christoph Lameter wrote:
> A simple implementation that only supports the word size and does not
> have a fallback mode (would require a spinlock).
> 
> And 32 and 64 bit support for cmpxchg_double. cmpxchg double uses
> the cmpxchg8b or cmpxchg16b instruction on x86 processors to compare
> and swap 2 machine words. This allows lockless algorithms to move more
> context information through critical sections.
> 
> Set a flag CONFIG_CMPXCHG_DOUBLE to signal the support of that feature
> during kernel builds.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
>  
> +config CMPXCHG_DOUBLE
> +	def_bool X86_64 || (X86_32 && !M386)
> +

CMPXCHG16B is not a baseline feature for the Linux x86-64 build, and
CMPXCHG8G is a Pentium, not a 486, feature.

Nacked-by: H. Peter Anvin <hpa@zytor.com>

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
