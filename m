Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
References: <Pine.LNX.4.21.0007111938241.3644-100000@inspiron.random>
	<ytt8zv8mt61.fsf@serpe.mitica> <396B8A38.D7FF17B5@norran.net>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Roger Larsson's message of "Tue, 11 Jul 2000 22:57:28 +0200"
Date: 12 Jul 2000 00:49:40 +0200
Message-ID: <ytt3dlgmge3.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "roger" == Roger Larsson <roger.larsson@norran.net> writes:

Hi

roger> Problem is that you have to age all pages, at some point the newly read
roger> pages will be older than the almost never reused ones.

The almost never reused pages is ok for them to go to swap, they are
good candidates, i.e. candidates to go to swap:
     1- unused pages
     2- almost unused pages

roger> Note: You can not avoid ageing all pages. If not an easy attack would be
roger> to reread some pages over and over... (they would never go away...)

I wast to age all the pages.  That is not an attack, how do you
differentiate a program that touches its pages from that.  It is ok to
do that.

Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
