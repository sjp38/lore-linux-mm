Received: from copernico ([212.216.186.165]) by fep01-svc.tin.it
          (InterMail v4.0 201-221-105) with SMTP
          id <19990615174020.EPLG12536.fep01-svc@copernico>
          for <linux-mm@kvack.org>; Tue, 15 Jun 1999 19:40:20 +0200
Message-Id: <4.1.19990615122732.00942160@box4.tin.it>
Message-Id: <4.1.19990615122732.00942160@box4.tin.it>
Date: Tue, 15 Jun 1999 12:28:06 +0200
From: Antonino Sabetta <copernico@tin.it>
Subject: Re: process selection
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>2. Also, in swap_out, it might make sense to steal more than a
>single page from a victim process, to balance the overhead of
>scanning all the processes.
Or at least, steal more that a single page if the process owns a "big"
number of pages.
--

+---------------------------------+
| A n t o n i n o   S a b e t t a |
|  sabetta@ieee.ing.uniroma1.it   |
|        ICQ:    39918730         |
+---------------------------------+
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
