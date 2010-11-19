Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E684B6B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 12:09:43 -0500 (EST)
Date: Fri, 19 Nov 2010 11:09:36 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: percpu: Implement this_cpu_add,sub,dec,inc_return
In-Reply-To: <1290183158.3034.145.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1011191108240.3976@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>  <alpine.DEB.2.00.1011100939530.23566@router.home>  <1290018527.2687.108.camel@edumazet-laptop>  <alpine.DEB.2.00.1011190941380.32655@router.home>  <1290181870.3034.136.camel@edumazet-laptop>
 <alpine.DEB.2.00.1011190958230.2360@router.home> <1290183158.3034.145.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2010, Eric Dumazet wrote:

> By the way, is your patch really ok ?
>
> xadd %0,foo   returns in %0 the previous value of the memory, not the
> value _after_ the operation.
>
> This is why we do in arch/x86/include/asm/atomic.h :
>
> static inline int atomic_add_return(int i, atomic_t *v)
> ...
>
>         __i = i;
>         asm volatile(LOCK_PREFIX "xaddl %0, %1"
>                      : "+r" (i), "+m" (v->counter)
>                      : : "memory");
>         return i + __i;
> ...

Ok so rename the macros to this_cpu_return_inc/dec/add/sub?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
