Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F0326B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:46:11 -0400 (EDT)
Subject: Re: kmemleak hexdump proposal
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090714140349.GA3145@localdomain.by>
References: <20090629201014.GA5414@localdomain.by>
	 <1247566033.28240.46.camel@pc1117.cambridge.arm.com>
	 <20090714103356.GA2929@localdomain.by>
	 <1247567641.28240.51.camel@pc1117.cambridge.arm.com>
	 <20090714105709.GB2929@localdomain.by>
	 <1247578781.28240.92.camel@pc1117.cambridge.arm.com>
	 <20090714140349.GA3145@localdomain.by>
Content-Type: text/plain
Date: Tue, 14 Jul 2009 15:17:42 +0100
Message-Id: <1247581062.28240.97.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-07-14 at 17:03 +0300, Sergey Senozhatsky wrote:
> On (07/14/09 14:39), Catalin Marinas wrote:
> > On Tue, 2009-07-14 at 13:57 +0300, Sergey Senozhatsky wrote:
> > [...]
> > > +/*
> > > + * Printing of the objects hex dump to the seq file. The number on lines
> > > + * to be printed is limited to HEX_MAX_LINES to prevent seq file spamming.
> > > + * The actual number of printed bytes depends on HEX_ROW_SIZE.
> > > + * It must be called with the object->lock held.
> > > + */
> > [...]
> > 
> > The patch looks fine. Could you please add a description and
> > Signed-off-by line?
> > 
> 
> Sure. During 30-40 minutes (sorry, I'm a bit busy now). OK?

There is no hurry, sometime in the next few weeks :-)

> Should I update Documentation/kmemeleak.txt either?

I don't think this is needed as it doesn't say much about the format of
the debug/kmemleak file (and that's pretty clear, no need to explain
what a hex dump means).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
