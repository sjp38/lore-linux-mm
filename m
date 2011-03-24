Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 271F08D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:51:54 -0400 (EDT)
Received: by fxm18 with SMTP id 18so396607fxm.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:51:52 -0700 (PDT)
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Eric Dumazet <eric.dumazet@gmail.com>
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
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Mar 2011 19:51:48 +0100
Message-ID: <1300992708.3747.211.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le jeudi 24 mars 2011 A  13:47 -0500, Christoph Lameter a A(C)crit :

> Hmmm.. Could be. KVM would not really disable interrupts so this may
> explain that the test case works here.
> 
> Simple fix would be to do a load before the cli I guess.
> 

Hmm... 

If we have a preemption and migration right after this load...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
