Date: Fri, 13 Oct 2000 17:20:10 -0700
Message-Id: <200010140020.RAA03611@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20001013155750.B29761@twiddle.net> (message from Richard
	Henderson on Fri, 13 Oct 2000 15:57:50 -0700)
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
References: <20001013141723.C29525@twiddle.net> <E13kDcJ-0001fX-00@the-village.bc.nu> <20001013155750.B29761@twiddle.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rth@twiddle.net
Cc: alan@lxorguk.ukuu.org.uk, davej@suse.de, tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   Either that or adjust how we do atomic operations.  I can do 64-bit
   atomic widgetry, but not with the code as written.

Ultra can do it as well, and as far as I understand it ia64 64-bit
atomic_t's shouldn't be a problem either.

I would suggest we make a atomic64_t or similar different type.
The space savings from using 32-bit normal atomic_t in all other
situations is of real value.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
