Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 225858D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:36:58 -0400 (EDT)
Date: Thu, 24 Mar 2011 20:36:47 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
Message-ID: <20110324193647.GA7957@elte.hu>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimWYCHEsZjswLpD-xDcu_cL=GqsMshKRtkHt5Vn@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Pekka Enberg <penberg@kernel.org> wrote:

> > -#if defined(CONFIG_CMPXCHG_LOCAL) && defined(CONFIG_PREEMPT)
> > +#ifdef CONFIG_CMPXCHG_LOCAL
> >        int cpu;
> >
> >        for_each_possible_cpu(cpu)
> >
> 
> Ingo, can you try this patch out, please? I'm compiling here but
> unfortunately I'm stuck with a really slow laptop...

Yes, it does the trick with the config i sent.

Tested-by: Ingo Molnar <mingo@elte.hu>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
