Date: Fri, 28 Jan 2000 11:29:14 -0500
Message-Id: <200001281629.LAA12522@tsx-prime.MIT.EDU>
From: "Theodore Y. Ts'o" <tytso@MIT.EDU>
In-reply-to: Alan Cox's message of Fri, 28 Jan 2000 14:40:30 +0000 (GMT),
	<E12ECZd-0004sr-00@the-village.bc.nu>
Subject: Re: 2.2.15pre4 VM fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: ink@jurassic.park.msu.ru, riel@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

   > > Please give this patch (against 2.2.15pre4) a solid beating
   > > and report back to us. Thanks all!
   > 
   > n_tty_open() has been caught with your patch.
   > Thanks!

   Do you know which drivers (serial,tty) you were using it. n_tty_open itself
   seems ok, but the caller may be guilty

The drivers don't call the line discpline open routine.  That honor is
reserved to the high-level tty layer --- see tty_set_ldisc in tty_io.c

							- Ted
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
