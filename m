Date: Wed, 22 Aug 2001 17:03:38 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
In-Reply-To: <E15ZfdG-0002M4-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.21.0108221703260.2685-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Jari Ruusu <jari.ruusu@pp.inet.fi>
List-ID: <linux-mm.kvack.org>


On Wed, 22 Aug 2001, Alan Cox wrote:

> > > Um the tlb optimisations go back to about 2.4.1-ac 8)
> > > My guess would be the vm changes you and marcelo did
> > 
> > The strange thing is that the recent vm tweaks don't
> > have any influence on the code paths which could cause
> > tasks segfaulting ...
> 
> They change reuse and timing patterns. I can believe we may have bugs left
> over from before that are now showing up. 

I'm looking at possibles races now... 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
