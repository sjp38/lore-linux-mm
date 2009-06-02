Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0E45F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:43:04 -0400 (EDT)
Subject: Re: [PATCH 3/7] percpu: clean up percpu variable definitions
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4A23BD20.5030500@kernel.org>
References: <1243846708-805-1-git-send-email-tj@kernel.org>
	 <1243846708-805-4-git-send-email-tj@kernel.org>
	 <20090601.024006.98975069.davem@davemloft.net>
	 <4A23BD20.5030500@kernel.org>
Content-Type: text/plain
Date: Tue, 02 Jun 2009 15:08:56 +1000
Message-Id: <1243919336.5308.32.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>, JBeulich@novell.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, tglx@linutronix.de, linux-kernel@vger.kernel.org, x86@kernel.org, ink@jurassic.park.msu.ru, rth@twiddle.net, linux@arm.linux.org.uk, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, jesper.nilsson@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, tony.luck@intel.com, takata@linux-m32r.org, geert@linux-m68k.org, monstr@monstr.eu, ralf@linux-mips.org, kyle@mcmartin.ca, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, chris@zankel.net, rusty@rustcorp.com.au, jens.axboe@oracle.com, davej@redhat.com, jeremy@xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-01 at 20:36 +0900, Tejun Heo wrote:
> > Whether the volatile is actually needed or not, it's bad to have this
> > kind of potential behavior changing nugget hidden in this seemingly
> > inocuous change.  Especially if you're the poor soul who ends up
> > having to debug it :-/
> 
> You're right.  Aieee... how do I feed volatile to the DEFINE macro.
> I'll think of something.

Or better, work with the cris maintainer to figure out whether it's
needed (it probably isn't) and have a pre-requisite patch that removes
it before your series :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
