Date: Mon, 25 Sep 2000 13:01:45 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: the new VMt
In-Reply-To: <E13dbZ7-0005Hg-00@the-village.bc.nu>
Message-ID: <Pine.GSO.4.21.0009251258160.16980-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Sep 2000, Alan Cox wrote:

> > > yep, i agree. I'm not sure what the biggest allocation is, some drivers
> > > might use megabytes or contiguous RAM?
> > 
> > Stupidity has no limits...
> 
> Unfortunately its frequently wired into the hardware to save a few cents on
> scatter gather logic.

Since when hardware folks became exempt from the rule above? 128K is
almost tolerable, there were requests for 64 _mega_bytes...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
