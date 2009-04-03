Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D83D76B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:53:35 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18901.52910.795773.284166@pilspetsen.it.uu.se>
Date: Fri, 3 Apr 2009 10:54:06 +0200
From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: Detailed Stack Information Patch [2/3]
In-Reply-To: <1238745668.8735.4.camel@matrix>
References: <1238511507.364.62.camel@matrix>
	<20090401193639.GB12316@elte.hu>
	<1238707547.3882.24.camel@matrix>
	<18901.48028.862826.66492@pilspetsen.it.uu.se>
	<1238745668.8735.4.camel@matrix>
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: Mikael Pettersson <mikpe@it.uu.se>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

Stefani Seibold writes:
 > Am Freitag, den 03.04.2009, 09:32 +0200 schrieb Mikael Pettersson:
 > > Stefani Seibold writes:
 > >  > I think a user space daemon will be the a good way if the /proc/*/maps
 > >  > or /proc/*/stack will provide the following information:
 > >  > 
 > >  > - start address of the stack
 > >  > - current address of the stack pointer
 > >  > - highest used address in the stack
 > > 
 > > You're assuming
 > > 1. a thread has exactly one stack
 > > 2. the stack is a single unbroken area
 > > 3. the kernel knows the location of this area
 > > 
 > > None of these assumptions are necessarily valid, esp. in
 > > the presence of virtualizers, managed runtimes, or mixed
 > > interpreted/JIT language implementations.
 > 
 > We are talking about the kernel view. And from this point a thread has
 > only one stack and it is a single mapped continuous area. There are only
 > one exception and that is the sigaltstack().

So you're proposing to have the kernel export data which,
while accurate from the kernel's limited view, may be
arbitrarily inaccurate for the user-space process in question?

Also I'm not sure you even need a kernel extension for the
optimistic case of a single simple stack. ptrace to get stack
pointer then scan /proc/$tid/maps to identify the corresponding
mapping should give the same information, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
