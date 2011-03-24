Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A7AB58D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:59:20 -0400 (EDT)
Date: Thu, 24 Mar 2011 19:59:03 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
Message-ID: <20110324185903.GA30510@elte.hu>
References: <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
 <20110324172653.GA28507@elte.hu>
 <alpine.DEB.2.00.1103241242450.32226@router.home>
 <AANLkTimMcP-GikCCndQppNBsS7y=4beesZ4PaD6yh5y5@mail.gmail.com>
 <alpine.DEB.2.00.1103241300420.32226@router.home>
 <AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>
 <alpine.DEB.2.00.1103241312280.32226@router.home>
 <1300990853.3747.189.camel@edumazet-laptop>
 <alpine.DEB.2.00.1103241346060.32226@router.home>
 <AANLkTik3rkNvLG-rgiWxKaPc-v9sZQq96ok0CXfAU+r_@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTik3rkNvLG-rgiWxKaPc-v9sZQq96ok0CXfAU+r_@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Pekka Enberg <penberg@kernel.org> wrote:

> On Thu, Mar 24, 2011 at 8:47 PM, Christoph Lameter <cl@linux.com> wrote:
> >
> > On Thu, 24 Mar 2011, Eric Dumazet wrote:
> >
> >> > this_cpu_cmpxchg16b_emu:
> >> >         pushf
> >> >         cli
> >> >
> >> >         cmpq %gs:(%rsi), %rax
> >
> >> Random guess
> >>
> >> Masking interrupts, and accessing vmalloc() based memory for the first
> >> time ?
> >
> > Hmmm.. Could be. KVM would not really disable interrupts so this may
> > explain that the test case works here.
> >
> > Simple fix would be to do a load before the cli I guess.
> 
> Btw, I tried Ingo's .config and it doesn't boot here so it's somehow
> .config related.

did you get a similar early crash as i? I'd not expect my .config to have all 
the drivers that are needed on your box.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
