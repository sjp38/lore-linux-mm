Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 15C996B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 16:48:22 -0400 (EDT)
Date: Wed, 18 May 2011 22:48:05 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/4] v6 Improve task->comm locking situation
Message-ID: <20110518204805.GA11427@elte.hu>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
 <20110518062554.GB2945@elte.hu>
 <1305745409.2915.178.camel@work-vm>
 <20110518123335.62785884.akpm@linux-foundation.org>
 <20110518194811.GD6225@elte.hu>
 <20110518125616.b57e1881.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110518125616.b57e1881.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 18 May 2011 21:48:11 +0200
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > Dunno, %ptc ties into lowlevel sprintf() and takes a spinlock!
> 
> yup, that's a problem.

If the lock is removed it looks useful.

> > Oh, out of morbid curiosity, mind providing a log of bigger past incidents 
> > where you had to stick pins into a doll of me? (In private mail, if the list is 
> > too long ;-)
> 
> http://0.tqn.com/d/urbanlegends/1/0/m/B/porcupine2.jpg

That looks manageable! I was hoping not to end up like this:

  http://i.telegraph.co.uk/multimedia/archive/00675/china_needle404_675809c.jpg

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
