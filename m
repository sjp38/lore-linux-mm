Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0C6DF6B005A
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 07:06:22 -0400 (EDT)
Date: Mon, 29 Jun 2009 14:08:12 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak hexdump proposal
Message-ID: <20090629110812.GC3731@localdomain.by>
References: <20090628173632.GA3890@localdomain.by>
 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
 <20090629101917.GA3093@localdomain.by>
 <1246270774.6364.9.camel@penberg-laptop>
 <20090629104553.GA3731@localdomain.by>
 <1246273108.21450.19.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246273108.21450.19.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/29/09 11:58), Catalin Marinas wrote:
> On Mon, 2009-06-29 at 13:45 +0300, Sergey Senozhatsky wrote:
> > BTW, printing it all the time we can spam kmemleak (in case there are objects sized 2K, 4K and so on).
> > That's why I wrote about hexdump=OBJECT_POINTER.
> 
> I'm more in favour of an on/off hexdump feature (maybe even permanently
> on) and with a limit to the number of bytes it displays. For larger
> blocks, the hexdump=OBJECT_POINTER is easily achievable in user space
> via /dev/kmem.
> 
Yeah. Good point.

> My proposal is for an always on hexdump but with no more than 2-3 lines
> of hex values. 
I like it.

> As Pekka said, I should get it into linux-next before the
> next merging window.
I'll send new patch to you (today evening)/(tomorrow). 
Ok?

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
