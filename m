Date: Wed, 16 Aug 2000 11:39:17 -0700
Message-Id: <200008161839.LAA09544@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <200008161847.LAA84163@google.engr.sgi.com> (message from Kanoj
	Sarcar on Wed, 16 Aug 2000 11:47:49 -0700 (PDT))
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008161847.LAA84163@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: sct@redhat.com, roman@augan.comsct@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

   I guess finally, drivers will either get one or a list of

   1. struct page or

Make this "struct page and offset", a page is not enough by itself to
indicate all the necessary information, you need an offset within the
page as well.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
