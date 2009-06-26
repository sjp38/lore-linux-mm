Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5098F6B005D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 04:52:55 -0400 (EDT)
Subject: Re: kmemleak suggestion (long message)
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090626085056.GC3451@localdomain.by>
References: <20090625221816.GA3480@localdomain.by>
	 <20090626065923.GA14078@elte.hu>
	 <84144f020906260007u3e79086bv91900e487ba0fb50@mail.gmail.com>
	 <20090626081452.GB3451@localdomain.by>
	 <1246004270.27533.16.camel@penberg-laptop>
	 <20090626085056.GC3451@localdomain.by>
Content-Type: text/plain
Date: Fri, 26 Jun 2009 09:54:23 +0100
Message-Id: <1246006463.30717.12.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-26 at 11:50 +0300, Sergey Senozhatsky wrote:
> On (06/26/09 11:17), Pekka Enberg wrote:
> > Well, the thing is, I am not sure it's needed if we implement Ingo's
> > suggestion. After all, syslog is no longer spammed very hard and you can
> > do all the filtering in userspace when you read /debug/mm/kmemleak file,
> > no?
> 
> Well, we just move 'spam' out of syslog. Not dealing with 'spam' itself.
> I'm not sure about 'filtering in userspace when you read'. Suppose I use
> 'tail -f /debug/mm/kmemleak'. How can I easy suppress printing of (for example):

I don't have a strong opinion on this patch at the moment, I'll have a
look later today.

> Or any report with tty_ldisc_try_get (ppp generates tons of them).

BTW, that's a real leak IMHO (posted a patch yesterday in reply to the
initial report to Alan Cox).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
