Date: Thu, 17 Aug 2000 12:30:42 -0700
Message-Id: <200008171930.MAA23963@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <200008171932.MAA93790@google.engr.sgi.com> (message from Kanoj
	Sarcar on Thu, 17 Aug 2000 12:32:35 -0700 (PDT))
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008171932.MAA93790@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.redhat.com, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

BTW, I've sed s/vger.rutgers.edu/vger.redhat.com/

   Wait! You are saying you have a scheme that will prevent writers 
   from writing buggy code that happens to work only on 32Mb i386 ...
   Go ahead, I am all ears :-)

I understand your point, but please understand mine.

One might laugh, but after I read and really considered some of the
points made by the author of "Writing Solid Code" in that book, I
realized that one of my jobs as someone creating an API is that I
should be trying as hard as possible to design it such that it is next
to impossible to misuse it.

Secondly, I learned that I shouldn't be adding API's spuriously
because it will end up being maintained forever, re: the
kern_addr_looks_ok sillyness :-)

So anyways, I was probably being overly anal for this particular case.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
