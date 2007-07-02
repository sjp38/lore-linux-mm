Received: by wa-out-1112.google.com with SMTP id m33so2318550wag
        for <linux-mm@kvack.org>; Mon, 02 Jul 2007 10:26:13 -0700 (PDT)
Message-ID: <6934efce0707021026wad68bbar2d239d0cb7954ea0@mail.gmail.com>
Date: Mon, 2 Jul 2007 10:26:13 -0700
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: vm/fs meetup in september?
In-Reply-To: <200706301758.16607.a1426z@gawab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070624042345.GB20033@wotan.suse.de>
	 <20070630093243.GD22354@infradead.org>
	 <87bqexiwu3.wl%peter@chubb.wattle.id.au>
	 <200706301758.16607.a1426z@gawab.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Boldi <a1426z@gawab.com>
Cc: peter@chubb.wattle.id.au, Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Christoph> So what you mean is "swap on flash" ?  Defintively sounds
> > Christoph> like an interesting topic, although I'm not too sure it's
> > Christoph> all that filesystem-related.
>
> I wouldn't want to call it swap, as this carries with it block-io
> connotations.  It's really mmap on flash.

Yes it is really mmap on flash.  But you are "swapping" pages from RAM
to be mmap'ed on flash.  Also the flash-io complexities are similar to
the block-io layer.  I think "swap on flash" is fair.  Though that
might be confused with making swap work on a NAND flash, which is very
much like the current block-io approach.  "Mmappable swap on flash" is
more exact, I suppose.

> > You need either a block translation layer,
>
> Are you suggesting to go through the block layer to reach the flash?

Well the obvious route would be to have this management layer use the
MTD, I can't see anything wrong with that.

> > or a (swap) filesystem that
> > understands flash peculiarities in order to make such a thing work.
> > The standard Linux swap format will not work.
>
> Correct.
>
> BTW, you may want to have a look at my "[RFC] VM: I have a dream..." thread.

Interesting.  This idea does allow for swap to be access directly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
