Received: from adore.lightlink.com (kimoto@adore.lightlink.com [205.232.34.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA18676
	for <linux-mm@kvack.org>; Fri, 19 Jun 1998 11:02:03 -0400
From: Paul Kimoto <kimoto@lightlink.com>
Message-ID: <19980619110148.53909@adore.lightlink.com>
Date: Fri, 19 Jun 1998 11:01:48 -0400
Subject: Re: update re: fork() failures [in 2.1.103]
References: <19980618235448.18503@adore.lightlink.com> <Pine.LNX.3.96.980619093210.6052C-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.980619093210.6052C-100000@mirkwood.dummy.home>; from Rik van Riel on Fri, Jun 19, 1998 at 09:33:54AM +0200
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 19, 1998 at 09:33:54AM +0200, Rik van Riel wrote:
> I wonder what kind of software / networking app you are using,
> and what memory usage those programs have...

It's a mixed libc5/libc6 system.  
Here is a snapshot of the Top 20 in RSS:

%CPU %MEM  SIZE   RSS
 1.3 18.9 13552  5876 Xwrapper        XFree 3.3.2.2
 1.0 18.4 10612  5716 netscape        3.01
 0.0  5.6  4508  1740 kermitbeta      6.1.193 Beta.05
 1.2  5.1  4072  1584 rvplayer        5.0.0.35
 0.0  3.7  4372  1176 kermitbeta
 0.0  3.7  4372  1168 kermitbeta
 0.0  2.9  1824   908 named           8.1.2
 0.0  2.9   960   908 xntpd           3-5.91 (locked into memory)
 0.0  2.8  2584   876 xterm
 0.0  2.4  2420   748 xterm
 0.0  2.3  1448   716 zsh             3.1.4
 0.0  2.1  1380   676 zsh
 0.0  2.1  1380   676 zsh
 0.0  2.1  1404   668 perl            5.004_04
 0.0  1.9  1512   592 gnuplot_x11     3.5 (3.50.1.17)
 0.0  1.9  2164   592 xload
 0.0  1.6   932   520 pppd            2.3.5
95.7  1.6  9364   520 mprime          15.4.2 (internet Mersenne prime search)
 0.0  1.5  1756   496 gnuplot
 0.0  1.5   836   488 ps              1.2.4

	-Paul <kimoto@lightlink.com>
	 [please cc: relevant messages to me]
