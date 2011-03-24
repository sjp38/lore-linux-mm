Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E5C6C8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:47:27 -0400 (EDT)
Date: Thu, 24 Mar 2011 13:47:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <1300990853.3747.189.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1103241346060.32226@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>  <20110324142146.GA11682@elte.hu>  <alpine.DEB.2.00.1103240940570.32226@router.home>  <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>  <20110324172653.GA28507@elte.hu>
 <alpine.DEB.2.00.1103241242450.32226@router.home>  <AANLkTimMcP-GikCCndQppNBsS7y=4beesZ4PaD6yh5y5@mail.gmail.com>  <alpine.DEB.2.00.1103241300420.32226@router.home>  <AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>  <alpine.DEB.2.00.1103241312280.32226@router.home>
 <1300990853.3747.189.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On Thu, 24 Mar 2011, Eric Dumazet wrote:

> > this_cpu_cmpxchg16b_emu:
> >         pushf
> >         cli
> >
> >         cmpq %gs:(%rsi), %rax

> Random guess
>
> Masking interrupts, and accessing vmalloc() based memory for the first
> time ?

Hmmm.. Could be. KVM would not really disable interrupts so this may
explain that the test case works here.

Simple fix would be to do a load before the cli I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
