Message-ID: <B83C33A4F7B6D311A3CA00805F85FBB863C59E@ems2.glam.ac.uk>
From: "Jones D (ISaCS)" <djones2@glam.ac.uk>
Subject: RE: [PATCH] Recent VM fiasco - fixed
Date: Thu, 11 May 2000 12:26:37 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Rik van Riel' <riel@conectiva.com.br>, Simon Kirby <sim@stormix.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> There probably are some good bits in the classzone patch, but
> it also backs out bugfixes for bugs which have been proven to
> exist and fixed by those fixes. ;(
> 
> It would be nice if Andrea could separate the good bits from
> the bad bits and make a somewhat cleaner patch...

As I've been playing with invalidate_inode_pages for the last few
days, this section of Andrea's classzone diff caught my eye.

I noticed that in Andrea's version, if a page is locked, then it is just
ignored, and never freed.  He reduced the complexity of the function, and
sped it up immeasuarably, but aparently at the expense of leaking pages.
I've not looked at the rest of the patch, so my judgement is on the basis
of this section alone.

Andrea, for an improved version of that function see the patch I sent
yesterday.

d.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
