Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BA8A86B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:49:32 -0400 (EDT)
Date: Mon, 29 Jun 2009 13:52:46 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak hexdump proposal
Message-ID: <20090629105246.GB3731@localdomain.by>
References: <20090628173632.GA3890@localdomain.by>
 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
 <20090629101917.GA3093@localdomain.by>
 <1246270774.6364.9.camel@penberg-laptop>
 <1246271880.21450.13.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246271880.21450.13.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/29/09 11:38), Catalin Marinas wrote:
> On Mon, 2009-06-29 at 13:19 +0300, Pekka Enberg wrote:
> > On Mon, 2009-06-29 at 13:19 +0300, Sergey Senozhatsky wrote:
> > > Well, it's not easy to come up with something strong. 
> > > I agree, that stack gives you almost all you need.
> > > 
> > > HEX dump can give you a _tip_ in case you're not sure. 
> > 
> > Don't get me wrong, I'm not against it in any way. If Catalin is
> > interested in merging this kind of functionality, go for it! You might
> > want to consider unconditionally enabling the hexdump. If the
> > information is valuable, we should print it all the time.
> 
> Though I prefer to do as much as possible in user space, 
Agreed. Good example is 'function filtering' ;)

> I think this feature would be useful.
> 
So, I'll continue my work. (given patch didn't even passed ./checkpatch.pl).
Ok?

> Anyway, I may not include it before the next merging window (when is
> actually the best time for new features). Currently, my main focus is on
> reducing the false positives.
Sure. No problems.

> 
> -- 
> Catalin
> 

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
