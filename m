Subject: Re: VM problem with 2.4.8-ac9 (fwd)
Date: Wed, 22 Aug 2001 22:33:50 +0100 (BST)
In-Reply-To: <Pine.LNX.4.33L.0108221827330.31410-100000@duckman.distro.conectiva> from "Rik van Riel" at Aug 22, 2001 06:28:15 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15ZfdG-0002M4-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, Jari Ruusu <jari.ruusu@pp.inet.fi>
List-ID: <linux-mm.kvack.org>

> > Um the tlb optimisations go back to about 2.4.1-ac 8)
> > My guess would be the vm changes you and marcelo did
> 
> The strange thing is that the recent vm tweaks don't
> have any influence on the code paths which could cause
> tasks segfaulting ...

They change reuse and timing patterns. I can believe we may have bugs left
over from before that are now showing up. 

Alan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
