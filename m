Date: Wed, 18 Aug 1999 16:08:23 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <19990817111350.B296@bug.ucw.cz>
Message-ID: <Pine.LNX.4.10.9908181601390.4343-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@bug.ucw.cz>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I cleaned up the kmap interface yesterday (in linux/bigmem.h).

Now I am cleaning up the stuff still more putting all the bigmem common
code and variables in linux/mm/bigmem.c (separated by the arch specific
arch/i386/mm/bigmem.c) so there won't be duplicated sources if some other
arch (not only i386) will want to take advantage of the bigmem common
interface (I just heard some interest in this field ;).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
