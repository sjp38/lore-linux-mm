Received: from deliverator.sgi.com (deliverator.sgi.com [204.94.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA01329
	for <Linux-MM@kvack.org>; Mon, 17 May 1999 13:32:17 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905171731.KAA20435@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm2.0-2.2.9 unneccesary page force in by munlock
Date: Mon, 17 May 1999 10:31:57 -0700 (PDT)
In-Reply-To: <Pine.LNX.3.95.990517091025.10344C-100000@penguin.transmeta.com> from "Linus Torvalds" at May 17, 99 09:11:19 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> On Sun, 16 May 1999, Kanoj Sarcar wrote:
> > 
> > Hmm, my logic was a little bit different. Note that you can call munlock()
> > on a range even when a previous mlock() has not been done on the range (I
> > think that's not an munlock error in POSIX). In 2.2.9, this would end up
> > faulting in the pages, which doesn't need to happen ... (haven't really
> > thought whether "root" can erroneously force memory deadlocks this way)
> 
> Well, if you look closely, the mlock_fixup() routine tests whether
> lockedness has changed and returns early if it hasn't.. So in your case
> nothing at all would have been done..
> 
> 		Linus

Indeed, it does, my mistake ... it still makes sense to clean up the
code, as you mentioned originally ...

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
