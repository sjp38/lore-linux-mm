Subject: Re: Getting big areas of memory, in 2.3.x?
Date: Thu, 9 Dec 1999 22:26:45 +0000 (GMT)
In-Reply-To: <14416.10643.915336.498552@liveoak.engr.sgi.com> from "William J. Earl" at Dec 9, 99 02:13:39 pm
Content-Type: text
Message-Id: <E11wC1Q-0002fc-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "William J. Earl" <wje@cthulhu.engr.sgi.com>
Cc: mingo@chiara.csoma.elte.hu, jgarzik@mandrakesoft.com, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>      That is not the case for loadable (modular) drivers.  Loading st
> as a module, for example, after boot time sometimes works and sometimes does
> not, especially if you set the maximum buffer size larger (to, say, 128K,
> as is needed on some drives for good space efficiency).

Dont mix up crap code with crap hardware. Scsi generic had similar problems
and has been fixed. There are very very few non scatter-gather scsi controllers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
