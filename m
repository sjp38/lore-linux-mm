Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D9B9C8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:41:52 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so207434gwa.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 12:41:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324193647.GA7957@elte.hu>
References: <alpine.DEB.2.00.1103241300420.32226@router.home>
	<AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>
	<alpine.DEB.2.00.1103241312280.32226@router.home>
	<1300990853.3747.189.camel@edumazet-laptop>
	<alpine.DEB.2.00.1103241346060.32226@router.home>
	<AANLkTik3rkNvLG-rgiWxKaPc-v9sZQq96ok0CXfAU+r_@mail.gmail.com>
	<20110324185903.GA30510@elte.hu>
	<AANLkTi=66Q-8=AV3Y0K28jZbT3ddCHy9azWedoCC4Nrn@mail.gmail.com>
	<alpine.DEB.2.00.1103241404490.5576@router.home>
	<AANLkTimWYCHEsZjswLpD-xDcu_cL=GqsMshKRtkHt5Vn@mail.gmail.com>
	<20110324193647.GA7957@elte.hu>
Date: Thu, 24 Mar 2011 21:41:51 +0200
Message-ID: <AANLkTinBwKT3s=1En5Urs56gmt_zCNgPXnQzzy52Tgdo@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 24, 2011 at 9:36 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Pekka Enberg <penberg@kernel.org> wrote:
>
>> > -#if defined(CONFIG_CMPXCHG_LOCAL) && defined(CONFIG_PREEMPT)
>> > +#ifdef CONFIG_CMPXCHG_LOCAL
>> > =A0 =A0 =A0 =A0int cpu;
>> >
>> > =A0 =A0 =A0 =A0for_each_possible_cpu(cpu)
>> >
>>
>> Ingo, can you try this patch out, please? I'm compiling here but
>> unfortunately I'm stuck with a really slow laptop...
>
> Yes, it does the trick with the config i sent.
>
> Tested-by: Ingo Molnar <mingo@elte.hu>

Thanks, Ingo! Christoph, may I have your sign-off for the patch and
I'll send it to Linus?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
