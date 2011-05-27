Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A2D936B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 20:56:20 -0400 (EDT)
Message-ID: <4DDEF524.9000109@zytor.com>
Date: Thu, 26 May 2011 17:49:40 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
References: <20110516202605.274023469@linux.com>	 <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>	 <alpine.DEB.2.00.1105261315350.26578@router.home>	 <4DDE9C01.2090104@zytor.com>	 <alpine.DEB.2.00.1105261615130.591@router.home>	 <1306445159.2543.25.camel@edumazet-laptop>  <4DDEC6B4.4050509@zytor.com> <1306446303.2543.27.camel@edumazet-laptop>
In-Reply-To: <1306446303.2543.27.camel@edumazet-laptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 05/26/2011 02:45 PM, Eric Dumazet wrote:
>>
>> "+m" (*ptr) please...
>>
>> 	-hpa
> 
> Oh well, I guess I was fooled by :
> 
>  (arch/x86/include/asm/cmpxchg_32.h)
> 
> static inline void set_64bit(volatile u64 *ptr, u64 value)
> {
>         u32 low  = value;
>         u32 high = value >> 32;
>         u64 prev = *ptr;
> 
>         asm volatile("\n1:\t"
>                      LOCK_PREFIX "cmpxchg8b %0\n\t"
>                      "jnz 1b"
>                      : "=m" (*ptr), "+A" (prev)
>                      : "b" (low), "c" (high)
>                      : "memory");
> }
> 

That's =m because the operation implemented by the asm() statement as a
whole is an assignment; the memory location after the entire asm()
statement has executed does not depend on the input value.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
