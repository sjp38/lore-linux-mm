Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A98E56B005D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 04:27:12 -0400 (EDT)
Subject: Re: kmemleak suggestion (long message)
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1246004740.30717.3.camel@pc1117.cambridge.arm.com>
References: <20090625221816.GA3480@localdomain.by>
	 <20090626065923.GA14078@elte.hu>
	 <1246004740.30717.3.camel@pc1117.cambridge.arm.com>
Date: Fri, 26 Jun 2009 11:27:59 +0300
Message-Id: <1246004879.27533.18.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Sergey Senozhatsky <sergey.senozhatsky@mail.by>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-26 at 09:25 +0100, Catalin Marinas wrote:
> BTW, this was questioned in the past as well - do we still need the
> automatic scanning from a kernel thread? Can a user cron job just read
> the kmemleak file?

I think the kernel thread makes sense so that we get an early warning in
syslog. Ingo, what's your take on this from autoqa point of view?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
