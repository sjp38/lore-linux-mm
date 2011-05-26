Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B372A6B0023
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:38:05 -0400 (EDT)
Message-ID: <4DDEC6B4.4050509@zytor.com>
Date: Thu, 26 May 2011 14:31:32 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
References: <20110516202605.274023469@linux.com>	 <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>	 <alpine.DEB.2.00.1105261315350.26578@router.home>	 <4DDE9C01.2090104@zytor.com>	 <alpine.DEB.2.00.1105261615130.591@router.home> <1306445159.2543.25.camel@edumazet-laptop>
In-Reply-To: <1306445159.2543.25.camel@edumazet-laptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 05/26/2011 02:25 PM, Eric Dumazet wrote:
>>
>> +#define cmpxchg16b(ptr, o1, o2, n1, n2)				\
>> +({								\
>> +	char __ret;						\
>> +	__typeof__(o2) __junk;					\
>> +	__typeof__(*(ptr)) __old1 = (o1);			\
>> +	__typeof__(o2) __old2 = (o2);				\
>> +	__typeof__(*(ptr)) __new1 = (n1);			\
>> +	__typeof__(o2) __new2 = (n2);				\
>> +	asm volatile(LOCK_PREFIX_HERE "lock; cmpxchg16b (%%rsi);setz %1" \
> 
> If there is no emulation, why do you force rsi here ?
> 
> It could be something else, like "=m" (*ptr) ?
> 
> (same remark for other functions)
> 

"+m" (*ptr) please...

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
