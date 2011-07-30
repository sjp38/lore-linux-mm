Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0568C6B0169
	for <linux-mm@kvack.org>; Sat, 30 Jul 2011 02:33:35 -0400 (EDT)
Received: by wwj40 with SMTP id 40so3522106wwj.26
        for <linux-mm@kvack.org>; Fri, 29 Jul 2011 23:33:33 -0700 (PDT)
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <m2pqksznea.fsf@firstfloor.org>
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
	 <alpine.DEB.2.00.1107291002570.16178@router.home>
	 <m2pqksznea.fsf@firstfloor.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 30 Jul 2011 08:33:28 +0200
Message-ID: <1312007608.2873.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le vendredi 29 juillet 2011 A  16:18 -0700, Andi Kleen a A(C)crit :
> Christoph Lameter <cl@linux.com> writes:
> 
> > On Fri, 29 Jul 2011, Pekka Enberg wrote:
> >
> >> We haven't come up with a solution to keep struct page size the same but I
> >> think it's a reasonable trade-off.
> >
> > The change requires the page struct to be aligned to a double word
> > boundary. 
> 
> Why is that?
> 

Because cmpxchg16b is believed to require a 16bytes alignment.

http://siyobik.info/main/reference/instruction/CMPXCHG8B%2FCMPXCHG16B

64-Bit Mode Exceptions
...

#GP(0) 	If the memory address is in a non-canonical form. If memory
operand for CMPXCHG16B is not aligned on a 16-byte boundary. If
CPUID.01H:ECX.CMPXCHG16B[bit 13] = 0.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
