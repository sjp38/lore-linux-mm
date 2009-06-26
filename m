Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 98FD06B005D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 04:40:17 -0400 (EDT)
Subject: Re: kmemleak suggestion (long message)
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1246004879.27533.18.camel@penberg-laptop>
References: <20090625221816.GA3480@localdomain.by>
	 <20090626065923.GA14078@elte.hu>
	 <1246004740.30717.3.camel@pc1117.cambridge.arm.com>
	 <1246004879.27533.18.camel@penberg-laptop>
Content-Type: text/plain
Date: Fri, 26 Jun 2009 09:41:20 +0100
Message-Id: <1246005681.30717.8.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Sergey Senozhatsky <sergey.senozhatsky@mail.by>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-26 at 11:27 +0300, Pekka Enberg wrote:
> On Fri, 2009-06-26 at 09:25 +0100, Catalin Marinas wrote:
> > BTW, this was questioned in the past as well - do we still need the
> > automatic scanning from a kernel thread? Can a user cron job just read
> > the kmemleak file?
> 
> I think the kernel thread makes sense so that we get an early warning in
> syslog.

If we keep the automatic scanning I could also change the code so that
the debug/kmemleak file only shows what was found during the thread
scanning rather than trigger a new scan (this could be forced with
something like echo "scan=now" > debug/kmemleak).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
