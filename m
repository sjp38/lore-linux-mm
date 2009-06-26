Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BE6286B006A
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 04:41:22 -0400 (EDT)
Date: Fri, 26 Jun 2009 10:42:28 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: kmemleak suggestion (long message)
Message-ID: <20090626084228.GA9789@elte.hu>
References: <20090625221816.GA3480@localdomain.by> <20090626065923.GA14078@elte.hu> <1246004740.30717.3.camel@pc1117.cambridge.arm.com> <1246004879.27533.18.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246004879.27533.18.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@mail.by>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> On Fri, 2009-06-26 at 09:25 +0100, Catalin Marinas wrote:
>
> > BTW, this was questioned in the past as well - do we still need 
> > the automatic scanning from a kernel thread? Can a user cron job 
> > just read the kmemleak file?
> 
> I think the kernel thread makes sense so that we get an early 
> warning in syslog. Ingo, what's your take on this from autoqa 
> point of view?

it would be nice to have more relevant messages. Many of the 
messages seem false positives, right? So it would be nice to 
constrain kmemleak into a mode of operation that makes its 
backtraces worth looking at. A message about suspected leaks is 
definitely useful, it just shouldnt be printed too frequently.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
