Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 18:06:11 +0100 (BST)
In-Reply-To: <Pine.GSO.4.21.0009251258160.16980-100000@weyl.math.psu.edu> from "Alexander Viro" at Sep 25, 2000 01:01:45 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13dbhk-0005J0-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > > Stupidity has no limits...
> > 
> > Unfortunately its frequently wired into the hardware to save a few cents on
> > scatter gather logic.
> 
> Since when hardware folks became exempt from the rule above? 128K is
> almost tolerable, there were requests for 64 _mega_bytes...

Most cheap ass PCI hardware is built on the basis you can do linear 4Mb 
allocations. There is a reason for this. You can do that 4Mb allocation on
NT or Windows 9x


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
