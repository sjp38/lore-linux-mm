Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA12010
	for <linux-mm@kvack.org>; Tue, 23 Mar 1999 10:12:51 -0500
Date: Tue, 23 Mar 1999 15:16:54 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: LINUX-MM
In-Reply-To: <36F7A0CD.C1361112@imsid.uni-jena.de>
Message-ID: <Pine.LNX.4.03.9903231514290.10060-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 1999, Matthias Arnold wrote:

> Thanks for your reply.Unfortunately the memory is not (at least
> not completely) returned to the system after the program has
> finished (as the OS comand 'free' tells me).

Hmm, what version of the kernel are you using?

IIRC there's a slight bug in some of the newer kernels
where the swap cache isn't being freed when you exit
your program, but only later on when the system tries
to reclaim memory...

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Linux Memory Management site:  http://humbolt.geo.uu.nl/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
