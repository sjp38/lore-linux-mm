From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15137.17195.500288.181489@pizda.ninka.net>
Date: Fri, 8 Jun 2001 14:27:07 -0700 (PDT)
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106081614490.2422-100000@freak.distro.conectiva>
References: <Pine.LNX.4.31.0106081313500.3244-100000@penguin.transmeta.com>
	<Pine.LNX.4.21.0106081614490.2422-100000@freak.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti writes:
 > > and Davem tried that once with noticeable performance
 > > degradation from the added locking and list manipulation.
 > 
 > David, 
 > 
 > Could you please send me that code so I can work on it and try to reduce
 > the performance degradation and take a look at the what it gives us ?
 > 
 > And remember even if we have a performance degradation by the locking and
 > list manipulation by adding this "feature", it may bring us a big
 > advantage on the fair aging thing I described above.

Please search the linux-mm archives, Stephen Tweedie posted my patches
at some point long ago.

I deleted all my copies because that code does not deserve to live in
my opinion, and the problem ought to be attacked from another angle.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
