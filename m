Date: Sun, 25 May 2008 20:55:32 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: 2.6.26: x86/kernel/pci_dma.c: gfp |= __GFP_NORETRY ?
Message-ID: <20080525205532.3ed5e478@core>
In-Reply-To: <20080525163539.GA8405@one.firstfloor.org>
References: <20080521113028.GA24632@xs4all.net>
	<48341A57.1030505@redhat.com>
	<20080522084736.GC31727@one.firstfloor.org>
	<1211484343.30678.15.camel@localhost.localdomain>
	<1211657898.25661.2.camel@localhost.localdomain>
	<20080525163539.GA8405@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Miquel van Smoorenburg <miquels@cistron.nl>, Glauber Costa <gcosta@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi-suse@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Sun, 25 May 2008 18:35:39 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> > So how about linux-2.6.26-gfp-no-oom.patch (see previous mail) for
> > 2.6.26 
> 
> Changing the gfp once globally like you did is not right, because
> the different fallback cases have to be handled differently
> (see the different cases I discussed in my earlier mail)
> 
> Especially the 16MB zone allocation should never trigger the OOM killer.

That depends how much memory you have.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
