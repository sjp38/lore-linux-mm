Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9A36B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 03:55:02 -0400 (EDT)
Subject: Re: Detailed Stack Information Patch [2/3]
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <18901.48028.862826.66492@pilspetsen.it.uu.se>
References: <1238511507.364.62.camel@matrix>
	 <20090401193639.GB12316@elte.hu> <1238707547.3882.24.camel@matrix>
	 <18901.48028.862826.66492@pilspetsen.it.uu.se>
Content-Type: text/plain
Date: Fri, 03 Apr 2009 10:01:08 +0200
Message-Id: <1238745668.8735.4.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mikael Pettersson <mikpe@it.uu.se>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

Am Freitag, den 03.04.2009, 09:32 +0200 schrieb Mikael Pettersson:
> Stefani Seibold writes:
>  > I think a user space daemon will be the a good way if the /proc/*/maps
>  > or /proc/*/stack will provide the following information:
>  > 
>  > - start address of the stack
>  > - current address of the stack pointer
>  > - highest used address in the stack
> 
> You're assuming
> 1. a thread has exactly one stack
> 2. the stack is a single unbroken area
> 3. the kernel knows the location of this area
> 
> None of these assumptions are necessarily valid, esp. in
> the presence of virtualizers, managed runtimes, or mixed
> interpreted/JIT language implementations.

We are talking about the kernel view. And from this point a thread has
only one stack and it is a single mapped continuous area. There are only
one exception and that is the sigaltstack().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
