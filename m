Date: Fri, 28 Jan 2000 19:48:27 +0300
From: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Subject: Re: 2.2.15pre4 VM fix
Message-ID: <20000128194827.A23800@jurassic.park.msu.ru>
References: <20000128150948.A3816@jurassic.park.msu.ru> <E12ECZd-0004sr-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E12ECZd-0004sr-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Fri, Jan 28, 2000 at 02:40:30PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@nl.linux.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2000 at 02:40:30PM +0000, Alan Cox wrote:
> > n_tty_open() has been caught with your patch.
> > Thanks!
> 
> Do you know which drivers (serial,tty) you were using it. n_tty_open itself
> seems ok, but the caller may be guilty

It happened when ppp connection was terminated (remote end hangup).
Serial driver is Comtrol Rocketport. The problem is repeatable
(3 times last 20 hours), so I can investigate further to see who
is the caller.

Ivan.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
