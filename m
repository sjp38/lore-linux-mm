Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6DECF8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:43:31 -0400 (EDT)
Date: Thu, 24 Mar 2011 15:43:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <1300997290.2714.2.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1103241541560.8108@router.home>
References: <alpine.DEB.2.00.1103241300420.32226@router.home>  <AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>  <alpine.DEB.2.00.1103241312280.32226@router.home>  <1300990853.3747.189.camel@edumazet-laptop>  <alpine.DEB.2.00.1103241346060.32226@router.home>
  <AANLkTik3rkNvLG-rgiWxKaPc-v9sZQq96ok0CXfAU+r_@mail.gmail.com>  <20110324185903.GA30510@elte.hu>  <AANLkTi=66Q-8=AV3Y0K28jZbT3ddCHy9azWedoCC4Nrn@mail.gmail.com>  <alpine.DEB.2.00.1103241404490.5576@router.home>  <AANLkTimWYCHEsZjswLpD-xDcu_cL=GqsMshKRtkHt5Vn@mail.gmail.com>
  <20110324193647.GA7957@elte.hu>  <AANLkTinBwKT3s=1En5Urs56gmt_zCNgPXnQzzy52Tgdo@mail.gmail.com>  <alpine.DEB.2.00.1103241451060.5576@router.home> <1300997290.2714.2.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>, npiggin@kernel.dk, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Mar 2011, Eric Dumazet wrote:

> Thats strange, alloc_percpu() is supposed to zero the memory already ...

True.

> Are you sure its really this problem of interrupts being disabled ?

Guess so since Ingo and Pekka reported that it fixed the problem.

Tejun: Can you help us with this mystery?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
