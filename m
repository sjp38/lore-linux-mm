Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1018D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:33:31 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id oAELXRnV009454
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 13:33:27 -0800
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by kpbe11.cbf.corp.google.com with ESMTP id oAELXNVK031952
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 13:33:24 -0800
Received: by pwi9 with SMTP id 9so713694pwi.33
        for <linux-mm@kvack.org>; Sun, 14 Nov 2010 13:33:23 -0800 (PST)
Date: Sun, 14 Nov 2010 13:33:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3]mm/oom-kill: direct hardware access processes should
 get bonus
In-Reply-To: <20101114141913.E019.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011141330120.22262@chino.kir.corp.google.com>
References: <1289402093.10699.25.camel@localhost.localdomain> <1289402666.10699.28.camel@localhost.localdomain> <20101114141913.E019.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Figo.zhang" <zhangtianfei@leadcoretech.com>
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:

> > the victim should not directly access hardware devices like Xorg server,
> > because the hardware could be left in an unpredictable state, although 
> > user-application can set /proc/pid/oom_score_adj to protect it. so i think
> > those processes should get bonus for protection.
> > 
> > in v2, fix the incorrect comment.
> > in v3, change the divided the badness score by 4, like old heuristic for protection. we just
> > want the oom_killer don't select Root/RESOURCE/RAWIO process as possible.
> > 
> > suppose that if a user process A such as email cleint "evolution" and a process B with
> > ditecly hareware access such as "Xorg", they have eat the equal memory (the badness score is 
> > the same),so which process are you want to kill? so in new heuristic, it will kill the process B.
> > but in reality, we want to kill process A.
> > 
> > Signed-off-by: Figo.zhang <figo1802@gmail.com>
> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Sorry for the delay. I've sent completely revert patch to linus. It will
> disappear your headache, I believe. I'm sorry that our development
> caused your harm. We really don't want it.
> 

Oh please, your dramatics are getting better and better.

Figo.zhang never described a problem that was being addressed but rather 
proposed several different variants of a patch (some with CAP_SYS_ADMIN, 
some with CAP_SYS_RESOURCE, some with CAP_SYS_RAWIO, some with a 
combination, some with a 3% bonus, some with a order-of-2 bonus, etc) to 
return the same heuristic used in the old oom killer.  I asked several 
times to show the oom killer log from the problematic behavior and none 
were presented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
