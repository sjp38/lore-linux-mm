Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 75DE18D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:03:26 -0400 (EDT)
Received: by gxk23 with SMTP id 23so165609gxk.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 12:03:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324185903.GA30510@elte.hu>
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
	<20110324185903.GA30510@elte.hu>
Date: Thu, 24 Mar 2011 21:03:24 +0200
Message-ID: <AANLkTi=66Q-8=AV3Y0K28jZbT3ddCHy9azWedoCC4Nrn@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 24, 2011 at 8:59 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Pekka Enberg <penberg@kernel.org> wrote:
>
>> On Thu, Mar 24, 2011 at 8:47 PM, Christoph Lameter <cl@linux.com> wrote:
>> >
>> > On Thu, 24 Mar 2011, Eric Dumazet wrote:
>> >
>> >> > this_cpu_cmpxchg16b_emu:
>> >> > =A0 =A0 =A0 =A0 pushf
>> >> > =A0 =A0 =A0 =A0 cli
>> >> >
>> >> > =A0 =A0 =A0 =A0 cmpq %gs:(%rsi), %rax
>> >
>> >> Random guess
>> >>
>> >> Masking interrupts, and accessing vmalloc() based memory for the firs=
t
>> >> time ?
>> >
>> > Hmmm.. Could be. KVM would not really disable interrupts so this may
>> > explain that the test case works here.
>> >
>> > Simple fix would be to do a load before the cli I guess.
>>
>> Btw, I tried Ingo's .config and it doesn't boot here so it's somehow
>> .config related.
>
> did you get a similar early crash as i? I'd not expect my .config to have=
 all
> the drivers that are needed on your box.

It hanged here which is pretty much expected on this box if
kmem_cache_init() oopses. I'm now trying to see if I'm able to find
the config option that breaks things. CONFIG_PREEMPT_NONE is a
suspect:

penberg@tiger:~/linux$ grep PREEMPT ../config-ingo
# CONFIG_PREEMPT_RCU is not set
CONFIG_PREEMPT_NONE=3Dy
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
