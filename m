From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15137.18422.26069.486131@pizda.ninka.net>
Date: Fri, 8 Jun 2001 14:47:34 -0700 (PDT)
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106081658500.2422-100000@freak.distro.conectiva>
References: <15137.17195.500288.181489@pizda.ninka.net>
	<Pine.LNX.4.21.0106081658500.2422-100000@freak.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti writes:
 > How do you think the problem should be attacked, if you have any
 > opinion at all ?

All I know is that keeping track of anon areas is not the way
I would approach the problem.

Even if you get anon areas to work, they bloat up the common
case just to possibly make swapping a little big quicker.

I mean, it didn't degenerate to Solaris fork+exit latencies or
anything like that (that would be a huge challenge :-), but it did
show up quite noticably in the tests I had done at the time.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
