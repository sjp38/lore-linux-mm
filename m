Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BF7236B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:56:52 -0400 (EDT)
Date: Wed, 18 May 2011 12:56:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] v6 Improve task->comm locking situation
Message-Id: <20110518125616.b57e1881.akpm@linux-foundation.org>
In-Reply-To: <20110518194811.GD6225@elte.hu>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
	<20110518062554.GB2945@elte.hu>
	<1305745409.2915.178.camel@work-vm>
	<20110518123335.62785884.akpm@linux-foundation.org>
	<20110518194811.GD6225@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, 18 May 2011 21:48:11 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> Dunno, %ptc ties into lowlevel sprintf() and takes a spinlock!

yup, that's a problem.

> Oh, out of morbid curiosity, mind providing a log of bigger past incidents 
> where you had to stick pins into a doll of me? (In private mail, if the list is 
> too long ;-)

http://0.tqn.com/d/urbanlegends/1/0/m/B/porcupine2.jpg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
