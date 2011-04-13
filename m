Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DFFF8900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 02:54:20 -0400 (EDT)
Message-ID: <530486.50523.qm@web162020.mail.bf1.yahoo.com>
Date: Tue, 12 Apr 2011 23:54:05 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Regarding memory fragmentation using malloc....
In-Reply-To: <1302662256.2811.27.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, =?iso-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

Dear All,

I am trying to understand how memory fragmentation occurs in linux using ma=
ny malloc calls.
I am trying to reproduce the page fragmentation problem in linux 2.6.29.x o=
n a linux mobile(without Swap) using a small malloc(in loop) test program o=
f BLOCK_SIZE (64*(4*K)).
And then monitoring the page changes in /proc/buddyinfo after each operatio=
n.
>From the output I can see that the page values under buddyinfo keeps changi=
ng. But I am not able to relate these changes with my malloc BLOCK_SIZE.
I mean with my BLOCK_SIZE of (2^6 x 4K =3D=3D> 2^6 PAGES) the 2^6 th block =
under /proc/buddyinfo should change. But this is not the actual behaviour.
Whatever is the blocksize, the buddyinfo changes only for 2^0 or 2^1 or 2^2=
 or 2^3.

I am trying to measure the level of fragmentation after each page allocatio=
n.
Can somebody explain me in detail, how actually /proc/buddyinfo changes aft=
er each allocation and deallocation.


Thanks,
Pintu
=0A=0A=0A      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
