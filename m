Message-ID: <3AD22189.DD5B9657@linuxjedi.org>
Date: Mon, 09 Apr 2001 16:54:33 -0400
From: "David L. Parsley" <parsley@linuxjedi.org>
MIME-Version: 1.0
Subject: Re: [PATCH] swap_state.c thinko
References: <Pine.LNX.4.31.0104091316500.9383-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Mon, 9 Apr 2001, Alan Cox wrote:
> >
> > Given that strict address space management is not that hard would you
> > accept patches to allow optional non-overcommit in 2.5
> 
> I really doubt anybody wants to use a truly non-overcommit system.

Eh, how about embedded developers.  Like, say, Transmeta. ;-)  Things
get real ugly when my X terminal runs out of RAM - I gotta think it
would be better for mallocs to just fail in userspace.

regards,
	David

-- 
David L. Parsley
Network Administrator
Roanoke College
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
