Date: Tue, 31 Aug 2004 14:25:31 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040831172531.GA18184@logos.cnet>
References: <20040829141718.GD10955@suse.de> <200408311950.09641.karl.vogel@seagha.com> <20040831165250.GD11149@logos.cnet> <200408312024.32158.karl.vogel@seagha.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200408312024.32158.karl.vogel@seagha.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Karl Vogel <karl.vogel@seagha.com>
Cc: Andrew Morton <akpm@osdl.org>, karl.vogel@pandora.be, axboe@suse.de, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2004 at 08:24:31PM +0200, Karl Vogel wrote:
> On Tuesday 31 August 2004 18:52, Marcelo Tosatti wrote:
> > > Is there a concept of a minimum working set size of an application? (kind
> > > of the reverse of an RSS limit)
> >
> > Not really. A hungry memory app can starve the rest of the system.
> 
> I noticed that a few times on our spamassassin box :-)
> 
> > One thing: what kernel version are you using?
> 
> 2.6.9-rc1-bk3

Can you try the same tests with 2.6.8.1 and check the difference, pretty please?

> > I've seen extreme decreases in performance (interactivity) with hungry
> > memory apps with Rik's swap token code.
> 
> Decrease?!

Yep, its odd. Rik knows the exact reason.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
