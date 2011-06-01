Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7186B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 11:49:31 -0400 (EDT)
Message-ID: <4DE65E02.8080303@zytor.com>
Date: Wed, 01 Jun 2011 08:42:58 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
References: <20110516202605.274023469@linux.com>  <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>  <alpine.DEB.2.00.1105261315350.26578@router.home>  <4DDE9C01.2090104@zytor.com>  <alpine.DEB.2.00.1105261615130.591@router.home> <1306445159.2543.25.camel@edumazet-laptop> <alpine.DEB.2.00.1105311012420.18755@router.home> <4DE50632.90906@zytor.com> <alpine.DEB.2.00.1105311058030.19928@router.home> <4DE576EA.6070906@zytor.com> <alpine.DEB.2.00.1105311846230.31190@router.home> <4DE57FBB.8040408@zytor.com> <alpine.DEB.2.00.1106010910430.22901@router.home> <alpine.DEB.2.00.1106010945010.22901@router.home>
In-Reply-To: <alpine.DEB.2.00.1106010945010.22901@router.home>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On 06/01/2011 07:46 AM, Christoph Lameter wrote:
> +#define cmpxchg8b_local(ptr, o1, o2, n1, n2)			\
> +({								\
> +	char __ret;						\
> +	__typeof__(o2) __dummy;					\
> +	__typeof__(*(ptr)) __old1 = (o1);			\
> +	__typeof__(o2) __old2 = (o2);				\
> +	__typeof__(*(ptr)) __new1 = (n1);			\
> +	__typeof__(o2) __new2 = (n2);				\
> +	asm volatile("cmpxchg8b %2; setz %1"			\
> +		       : "=d"(__dummy), "=a"(__ret), "m+" (*ptr)\
> +		       : "a" (__old), "d"(__old2),		\
> +		         "b" (__new1), "c" (__new2),		\
> +		       : "memory");				\
> +	__ret; })

Another syntax error... did you even compile-test any of your patches on
32 bits?

> +#
> +# CMPXCHG_DOUBLE needs to be set to enable the kernel to use cmpxchg16/8b
> +# for cmpxchg_double if it find processor flags that indicate that the
> +# capabilities are available. CMPXCHG_DOUBLE only compiles in
> +# detection support. It needs to be set if there is a chance that processor
> +# supports these instructions.
> +#
> +config CMPXCHG_DOUBLE
> +	def_bool GENERIC_CPU || X86_GENERIC || !M386
> +

Still wrong.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
