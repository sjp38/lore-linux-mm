Subject: Re: 2.2.15pre4 VM fix
Date: Fri, 28 Jan 2000 14:40:30 +0000 (GMT)
In-Reply-To: <20000128150948.A3816@jurassic.park.msu.ru> from "Ivan Kokshaysky" at Jan 28, 2000 03:09:48 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12ECZd-0004sr-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

> > Please give this patch (against 2.2.15pre4) a solid beating
> > and report back to us. Thanks all!
> 
> n_tty_open() has been caught with your patch.
> Thanks!

Do you know which drivers (serial,tty) you were using it. n_tty_open itself
seems ok, but the caller may be guilty
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
