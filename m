Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA17113
	for <linux-mm@kvack.org>; Tue, 23 Mar 1999 19:39:39 -0500
Date: Wed, 24 Mar 1999 01:33:53 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: LINUX-MM
In-Reply-To: <Pine.LNX.4.05.9903240123100.4288-100000@laser.random>
Message-ID: <Pine.LNX.4.03.9903240130400.10060-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 1999, Andrea Arcangeli wrote:
> On Tue, 23 Mar 1999, Rik van Riel wrote:
> >On Tue, 23 Mar 1999, Matthias Arnold wrote:
> >
> >> Thanks for your reply.Unfortunately the memory is not (at least
> >> not completely) returned to the system after the program has
> >> finished (as the OS comand 'free' tells me).
> >
> >Hmm, what version of the kernel are you using?
> >
> >IIRC there's a slight bug in some of the newer kernels
> 
> I think at it as a feature and not a bug ;).

It is a bug when it causes other programs to fail
miserably...

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Linux Memory Management site:  http://humbolt.geo.uu.nl/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
