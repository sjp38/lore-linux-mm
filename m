Subject: Re: set_pte() is no longer atomic with PAE36.
Date: Thu, 2 Dec 1999 14:42:45 +0000 (GMT)
In-Reply-To: <199912021427.OAA03199@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Dec 2, 99 02:27:47 pm
Content-Type: text
Message-Id: <E11tXRX-0000sQ-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: mingo@redhat.com, torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> Modifying an existing pte (eg. for COW) is probably even harder: do we
> need to clear the page-present bit while we modify the high word?
> Simply setting the dirty or accessed bits should pose no such problem,
> but relocating a page looks as if it could bite here.

You can do 64bit atomic sets with lock cmpxchg8. It might just be slow though

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
