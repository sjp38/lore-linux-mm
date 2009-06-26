Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B34596B005D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 04:25:04 -0400 (EDT)
Subject: Re: kmemleak suggestion (long message)
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090626065923.GA14078@elte.hu>
References: <20090625221816.GA3480@localdomain.by>
	 <20090626065923.GA14078@elte.hu>
Content-Type: text/plain
Date: Fri, 26 Jun 2009 09:25:40 +0100
Message-Id: <1246004740.30717.3.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Sergey Senozhatsky <sergey.senozhatsky@mail.by>, Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-26 at 08:59 +0200, Ingo Molnar wrote:
> * Sergey Senozhatsky <sergey.senozhatsky@mail.by> wrote:
> > Currently kmemleak prints info about all objects. I guess 
> > sometimes kmemleak gives you more than you actually need.
> 
> It prints _a lot_ of info and spams the syslog. I lost crash info a 
> few days ago due to that: by the time i inspected a crashed machine 
> the tons of kmemleak output scrolled out the crash from the dmesg 
> buffer.
> 
> This is not acceptable.
> 
> Instead it should perhaps print _at most_ a single line every few 
> minutes, printing a summary about _how many_ leaked entries it 
> suspects, and should offer a /debug/mm/kmemleak style of file where 
> the entries can be read out from.

I agree as well. It already provides the /sys/kernel/debug/kmemleak
which triggers a scan and shows possible leaks. That's easily fixable.

BTW, this was questioned in the past as well - do we still need the
automatic scanning from a kernel thread? Can a user cron job just read
the kmemleak file?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
