Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0E7E36B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:46:31 -0400 (EDT)
Date: Thu, 25 Aug 2011 13:46:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
In-Reply-To: <1e295500-5d1f-45dd-aa5b-3d2da2cf1a62@email.android.com>
Message-ID: <alpine.DEB.2.00.1108251341230.27407@router.home>
References: <1313650253-21794-1-git-send-email-gthelen@google.com> <20110818144025.8e122a67.akpm@linux-foundation.org> <1314284272.27911.32.camel@twins> <alpine.DEB.2.00.1108251009120.27407@router.home> <1314289208.3268.4.camel@mulgrave>
 <alpine.DEB.2.00.1108251128460.27407@router.home> <986ca4ed-6810-426f-b32f-5c8687e3a10b@email.android.com> <alpine.DEB.2.00.1108251206440.27407@router.home> <1e295500-5d1f-45dd-aa5b-3d2da2cf1a62@email.android.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.bottomley@HansenPartnership.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-arch@vger.kernel.org

On Thu, 25 Aug 2011, James Bottomley wrote:

> >Well then what is "really risc"? RISC is an old beaten down marketing
> >term
> >AFAICT and ARM claims it too.
>
> Reduced Instruction Set Computer.  This is why we're unlikely to have
> complex atomic instructions: the principle of risc is that you build
> them up from basic ones.

RISC cpus have instruction to construct complex atomic actions by the cpu
as I have shown before for ARM.

Principles always have exceptions to them.

(That statement in itself is a principle that should have an exception I
guess. But then language often only makes sense when it contains
contradictions.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
