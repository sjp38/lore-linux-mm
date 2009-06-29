Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 468786B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 05:47:18 -0400 (EDT)
Subject: Re: kmemleak hexdump proposal
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
References: <20090628173632.GA3890@localdomain.by>
	 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 10:48:42 +0100
Message-Id: <1246268922.21450.3.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Sergey Senozhatsky <sergey.senozhatsky@mail.by>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-29 at 12:43 +0300, Pekka Enberg wrote:
> On Sun, Jun 28, 2009 at 8:36 PM, Sergey
> Senozhatsky<sergey.senozhatsky@mail.by> wrote:
> > What do you think about ability to 'watch' leaked region? (hex + ascii).
> > (done via lib/hexdump.c)
> 
> What's your use case for this? I'm usually more interested in the
> stack trace when there's a memory leak.

I once had a need for such feature when investigating a memory leak (it
was more like debugging kmemleak) but a script combining dd, od
and /dev/kmem did the trick (I also work in an embedded world where I
have a halting debugger connected most of the times).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
