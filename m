Date: Thu, 10 Aug 2000 19:24:32 -0700
Message-Id: <200008110224.TAA24476@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <200008101718.KAA33467@google.engr.sgi.com> (message from Kanoj
	Sarcar on Thu, 10 Aug 2000 10:18:49 -0700 (PDT))
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008101718.KAA33467@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

   Also, as I have suggested before, the pte_page implementation in
   sparc/sparc64 should be cleaned up

I took care of sparc64 and have asked Anton to deal with sparc32.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
