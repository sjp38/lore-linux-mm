Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 72A638D003B
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 05:57:52 -0400 (EDT)
Message-ID: <4D8F09EF.3020002@redhat.com>
Date: Sun, 27 Mar 2011 11:57:03 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
References: <alpine.DEB.2.00.1103221635400.4521@tiger>  <20110324142146.GA11682@elte.hu>  <alpine.DEB.2.00.1103240940570.32226@router.home>  <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>  <20110324172653.GA28507@elte.hu>  <alpine.DEB.2.00.1103241242450.32226@router.home>  <AANLkTimMcP-GikCCndQppNBsS7y=4beesZ4PaD6yh5y5@mail.gmail.com>  <alpine.DEB.2.00.1103241300420.32226@router.home>  <AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>  <alpine.DEB.2.00.1103241312280.32226@router.home> <1300990853.3747.189.camel@edumazet-laptop> <alpine.DEB.2.00.1103241346060.32226@router.home>
In-Reply-To: <alpine.DEB.2.00.1103241346060.32226@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@kernel.org>, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/24/2011 08:47 PM, Christoph Lameter wrote:
> On Thu, 24 Mar 2011, Eric Dumazet wrote:
>
> >  >  this_cpu_cmpxchg16b_emu:
> >  >          pushf
> >  >          cli
> >  >
> >  >          cmpq %gs:(%rsi), %rax
>
> >  Random guess
> >
> >  Masking interrupts, and accessing vmalloc() based memory for the first
> >  time ?
>
> Hmmm.. Could be. KVM would not really disable interrupts so this may
> explain that the test case works here.

kvm does really disable guest interrupts (it doesn't disable host 
interrupts, but these are invisible to the guest).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
