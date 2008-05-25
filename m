Date: Sun, 25 May 2008 23:02:16 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: 2.6.26: x86/kernel/pci_dma.c: gfp |= __GFP_NORETRY ?
Message-ID: <20080525230216.1fe1b216@core>
In-Reply-To: <20080525212350.GB8405@one.firstfloor.org>
References: <20080521113028.GA24632@xs4all.net>
	<48341A57.1030505@redhat.com>
	<20080522084736.GC31727@one.firstfloor.org>
	<1211484343.30678.15.camel@localhost.localdomain>
	<1211657898.25661.2.camel@localhost.localdomain>
	<20080525163539.GA8405@one.firstfloor.org>
	<20080525205532.3ed5e478@core>
	<20080525212350.GB8405@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Miquel van Smoorenburg <miquels@cistron.nl>, Glauber Costa <gcosta@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi-suse@firstfloor.org
List-ID: <linux-mm.kvack.org>

> No it doesn't because the lower zone protection basically never puts
> anything that is not GFP_DMA into the 16MB zone.
> 
> Just check yourself on your machine using sysrq.
> 
> That was one of the motivations behind the mask allocator design.

Try a 16MB embedded PC 

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
