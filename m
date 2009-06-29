Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B53DF6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:19:03 -0400 (EDT)
Subject: Re: kmemleak hexdump proposal
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090629101917.GA3093@localdomain.by>
References: <20090628173632.GA3890@localdomain.by>
	 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
	 <20090629101917.GA3093@localdomain.by>
Date: Mon, 29 Jun 2009 13:19:34 +0300
Message-Id: <1246270774.6364.9.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Catalin Marinas <catalin.marinas@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Sergey,

On Mon, 2009-06-29 at 13:19 +0300, Sergey Senozhatsky wrote:
> Well, it's not easy to come up with something strong. 
> I agree, that stack gives you almost all you need.
> 
> HEX dump can give you a _tip_ in case you're not sure. 

Don't get me wrong, I'm not against it in any way. If Catalin is
interested in merging this kind of functionality, go for it! You might
want to consider unconditionally enabling the hexdump. If the
information is valuable, we should print it all the time.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
