Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B0DAF8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:08:19 -0400 (EDT)
Received: by bwz17 with SMTP id 17so557492bwz.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 13:08:17 -0700 (PDT)
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1103241451060.5576@router.home>
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
	 <AANLkTinBwKT3s=1En5Urs56gmt_zCNgPXnQzzy52Tgdo@mail.gmail.com>
	 <alpine.DEB.2.00.1103241451060.5576@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Mar 2011 21:08:10 +0100
Message-ID: <1300997290.2714.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le jeudi 24 mars 2011 A  14:51 -0500, Christoph Lameter a A(C)crit :
> On Thu, 24 Mar 2011, Pekka Enberg wrote:
> 
> > Thanks, Ingo! Christoph, may I have your sign-off for the patch and
> > I'll send it to Linus?
> 
> 
> Subject: SLUB: Write to per cpu data when allocating it
> 
> It turns out that the cmpxchg16b emulation has to access vmalloced
> percpu memory with interrupts disabled. If the memory has never
> been touched before then the fault necessary to establish the
> mapping will not to occur and the kernel will fail on boot.
> 
> Fix that by reusing the CONFIG_PREEMPT code that writes the
> cpu number into a field on every cpu. Writing to the per cpu
> area before causes the mapping to be established before we get
> to a cmpxchg16b emulation.
> 


Thats strange, alloc_percpu() is supposed to zero the memory already ...

Are you sure its really this problem of interrupts being disabled ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
