Message-ID: <3D80B1C8.EE19E03D@earthlink.net>
Date: Thu, 12 Sep 2002 09:24:56 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: kiobuf interface / PG_locked flag
References: <3D8054D5.B385C83@scs.ch>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Martin Maletinsky wrote:
> 
> Hello,
> 
> I just read about the kiobuf interface in the Linux Device Driver book from Rubini/Corbet, and there is one point, which I don't understand:
> - map_user_kiobuf() forces the pages within a user space address range into physical memory, and increments their usage count, which subsequently prevents the pages from
> being swapped out.

While it's true that having a non-zero reference count will prevent
a page from being swapped out, such a page is still subject to
all normal VM operations. In particular, the VM might unmap
the page from your process, *decrement its reference count*, and
then swap it out.

> - lock_kiovec() sets the PG_locked flag for the pages in the kiobufs of a kiovec. The PG_locked flag prevents the pages from being swapped out, which is however already
> ensured by map_user_kiobuf().

I believe PG_locked will prevent the VM from unmapping the
page, which does, in fact, gaurantee that it won't be
swapped out.

Cheers,

-- Joe
  "I'd rather chew my leg off than maintain Java code, which
   sucks, 'cause I have a lot of Java code to maintain and
   the leg surgery is starting to get expensive." - Me
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
