From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14417.16577.210091.926383@liveoak.engr.sgi.com>
Date: Fri, 10 Dec 1999 10:04:49 -0800 (PST)
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <Pine.LNX.4.10.9912101437330.4472-100000@chiara.csoma.elte.hu>
References: <Pine.LNX.4.05.9912101308140.31379-100000@humbolt.nl.linux.org>
	<Pine.LNX.4.10.9912101437330.4472-100000@chiara.csoma.elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Rik van Riel <riel@nl.linux.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar writes:
...
 > this is possible (sans the relocation process which is a special thing
 > anyway), but why would we want to allocate large chunks of contiguous user
 > pages?
...

     To be able to use, for example, 2 or 4 MB pages on x86 to reduce
TLB thrashing (and, if the I/O path understands large pages, the software
overhead to set up large direct or raw I/O requests).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
