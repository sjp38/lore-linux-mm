Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 199A26B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:38:23 -0400 (EDT)
Subject: Re: kmemleak hexdump proposal
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1246270774.6364.9.camel@penberg-laptop>
References: <20090628173632.GA3890@localdomain.by>
	 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
	 <20090629101917.GA3093@localdomain.by>
	 <1246270774.6364.9.camel@penberg-laptop>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 11:38:00 +0100
Message-Id: <1246271880.21450.13.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Sergey Senozhatsky <sergey.senozhatsky@mail.by>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-29 at 13:19 +0300, Pekka Enberg wrote:
> On Mon, 2009-06-29 at 13:19 +0300, Sergey Senozhatsky wrote:
> > Well, it's not easy to come up with something strong. 
> > I agree, that stack gives you almost all you need.
> > 
> > HEX dump can give you a _tip_ in case you're not sure. 
> 
> Don't get me wrong, I'm not against it in any way. If Catalin is
> interested in merging this kind of functionality, go for it! You might
> want to consider unconditionally enabling the hexdump. If the
> information is valuable, we should print it all the time.

Though I prefer to do as much as possible in user space, I think this
feature would be useful.

Anyway, I may not include it before the next merging window (when is
actually the best time for new features). Currently, my main focus is on
reducing the false positives.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
