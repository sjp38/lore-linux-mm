Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E99C8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:55:57 -0400 (EDT)
Received: by yxt33 with SMTP id 33so181734yxt.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:55:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1103241346060.32226@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
	<20110324142146.GA11682@elte.hu>
	<alpine.DEB.2.00.1103240940570.32226@router.home>
	<AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
	<20110324172653.GA28507@elte.hu>
	<alpine.DEB.2.00.1103241242450.32226@router.home>
	<AANLkTimMcP-GikCCndQppNBsS7y=4beesZ4PaD6yh5y5@mail.gmail.com>
	<alpine.DEB.2.00.1103241300420.32226@router.home>
	<AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>
	<alpine.DEB.2.00.1103241312280.32226@router.home>
	<1300990853.3747.189.camel@edumazet-laptop>
	<alpine.DEB.2.00.1103241346060.32226@router.home>
Date: Thu, 24 Mar 2011 20:55:54 +0200
Message-ID: <AANLkTik3rkNvLG-rgiWxKaPc-v9sZQq96ok0CXfAU+r_@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 24, 2011 at 8:47 PM, Christoph Lameter <cl@linux.com> wrote:
>
> On Thu, 24 Mar 2011, Eric Dumazet wrote:
>
>> > this_cpu_cmpxchg16b_emu:
>> > =A0 =A0 =A0 =A0 pushf
>> > =A0 =A0 =A0 =A0 cli
>> >
>> > =A0 =A0 =A0 =A0 cmpq %gs:(%rsi), %rax
>
>> Random guess
>>
>> Masking interrupts, and accessing vmalloc() based memory for the first
>> time ?
>
> Hmmm.. Could be. KVM would not really disable interrupts so this may
> explain that the test case works here.
>
> Simple fix would be to do a load before the cli I guess.

Btw, I tried Ingo's .config and it doesn't boot here so it's somehow
.config related.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
