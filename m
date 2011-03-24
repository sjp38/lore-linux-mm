Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4654A8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:02:23 -0400 (EDT)
Date: Thu, 24 Mar 2011 14:02:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <1300992708.3747.211.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1103241401090.5576@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>  <20110324142146.GA11682@elte.hu>  <alpine.DEB.2.00.1103240940570.32226@router.home>  <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>  <20110324172653.GA28507@elte.hu>
 <alpine.DEB.2.00.1103241242450.32226@router.home>  <AANLkTimMcP-GikCCndQppNBsS7y=4beesZ4PaD6yh5y5@mail.gmail.com>  <alpine.DEB.2.00.1103241300420.32226@router.home>  <AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>  <alpine.DEB.2.00.1103241312280.32226@router.home>
  <1300990853.3747.189.camel@edumazet-laptop>  <alpine.DEB.2.00.1103241346060.32226@router.home> <1300992708.3747.211.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1430651396-1300993340=:5576"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1430651396-1300993340=:5576
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 24 Mar 2011, Eric Dumazet wrote:

> Le jeudi 24 mars 2011 =C3=A0 13:47 -0500, Christoph Lameter a =C3=A9crit =
:
>
> > Hmmm.. Could be. KVM would not really disable interrupts so this may
> > explain that the test case works here.
> >
> > Simple fix would be to do a load before the cli I guess.
> >
>
> Hmm...
>
> If we have a preemption and migration right after this load...

Cannot be the issue here since init_kmem_cache_cpus already
touches the per cpu data. At least if CONFIG_PREEMPT is on.
Is it on?


void init_kmem_cache_cpus(struct kmem_cache *s)
{
#if defined(CONFIG_CMPXCHG_LOCAL) && defined(CONFIG_PREEMPT)
        int cpu;

        for_each_possible_cpu(cpu)
                per_cpu_ptr(s->cpu_slab, cpu)->tid =3D init_tid(cpu);
#endif

}



---1463811839-1430651396-1300993340=:5576--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
