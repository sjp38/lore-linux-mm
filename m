Message-Id: <m0zZLFw-0007V3C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: mmap() for a cluster of pages
Date: Fri, 30 Oct 1998 20:34:47 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.981030140129.1612B-100000@as200.spellcast.com> from "Benjamin C.R. LaHaise" at Oct 30, 98 02:18:33 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, pokam@cs.tu-berlin.de, Linux-MM@kvack.org, number6@the-village.bc.nu
List-ID: <linux-mm.kvack.org>

> which my eyes blindly skipped.  Other code performing the same trick looks
> right too (the bttv driver; the fb stuff looks like it has its buffers
> outside of normal RAM). 

bttv uses vmalloced pages

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
