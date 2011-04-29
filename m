Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C76AC900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 05:34:50 -0400 (EDT)
Date: Fri, 29 Apr 2011 11:34:13 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
In-Reply-To: <20110429004255.GF2191@linux.vnet.ibm.com>
Message-ID: <alpine.LFD.2.02.1104291133100.3005@ionos>
References: <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com> <alpine.LFD.2.02.1104282044120.3005@ionos> <20110428222301.0b745a0a@neptune.home> <alpine.LFD.2.02.1104282227340.3005@ionos> <20110428224444.43107883@neptune.home> <alpine.LFD.2.02.1104282251080.3005@ionos>
 <1304027480.2971.121.camel@work-vm> <alpine.LFD.2.02.1104282353140.3005@ionos> <BANLkTi=uDstjKEQaPOkxX94NxMQU2Pu5gA@mail.gmail.com> <BANLkTikS-PN0PDBbCz3emWRBL90sGMY+Kg@mail.gmail.com> <20110429004255.GF2191@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: sedat.dilek@gmail.com, john stultz <johnstul@us.ibm.com>, =?ISO-8859-15?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Mike Galbraith <efault@gmx.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, 28 Apr 2011, Paul E. McKenney wrote:
> On Fri, Apr 29, 2011 at 01:35:44AM +0200, Sedat Dilek wrote:
> >  01:35:17 up 45 min,  3 users,  load average: 0.45, 0.57, 1.27
> > 
> > Thanks to all involved people helping to kill that bug (Come on Paul, smile!).
> 
> Woo-hoo!!!!
> 
> Many thanks to Thomas for tracking this down -- it is fair to say that
> I never would have thought to look at timer initialization!  ;-)

Many thanks to the reporters who provided all the information and
tested all the random debug patches we threw at them !

       tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
