Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E685E6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:42:52 -0400 (EDT)
Date: Mon, 29 Jun 2009 13:45:53 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak hexdump proposal
Message-ID: <20090629104553.GA3731@localdomain.by>
References: <20090628173632.GA3890@localdomain.by>
 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
 <20090629101917.GA3093@localdomain.by>
 <1246270774.6364.9.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246270774.6364.9.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Sergey Senozhatsky <sergey.senozhatsky@mail.by>, Catalin Marinas <catalin.marinas@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/29/09 13:19), Pekka Enberg wrote:
> Hi Sergey,
> 
> On Mon, 2009-06-29 at 13:19 +0300, Sergey Senozhatsky wrote:
> > Well, it's not easy to come up with something strong. 
> > I agree, that stack gives you almost all you need.
> > 
> > HEX dump can give you a _tip_ in case you're not sure. 
> 
> Don't get me wrong, I'm not against it in any way. 
I don't think so ;) _IF_ even so - it's absolutely normal, to my mind.

> If Catalin is interested in merging this kind of 
> functionality, go for it! You might want to consider unconditionally
> enabling the hexdump. If the information is valuable, we should print
> it all the time.
I guess it's valuable enougth to print it, but not valuable enougth to print it all the time.
So, let me say - it's valuable enougth to print 'on demand', I guess. (I may be wrong).

BTW, printing it all the time we can spam kmemleak (in case there are objects sized 2K, 4K and so on).
That's why I wrote about hexdump=OBJECT_POINTER.

>
> 			Pekka
> 

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
