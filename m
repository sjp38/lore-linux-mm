Date: Mon, 8 May 2000 14:43:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <dnzoq1x8j3.fsf@magla.iskon.hr>
Message-ID: <Pine.LNX.4.21.0005081442030.20790-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005081442032.20790@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 8 May 2000, Zlatko Calusic wrote:

> BTW, this patch mostly *removes* cruft recently added, and
> returns to the known state of operation.

Which doesn't work.

Think of a 1GB machine which has a 16MB DMA zone,
a 950MB normal zone and a very small HIGHMEM zone.

With the old VM code the HIGHMEM zone would be
swapping like mad while the other two zones are
idle.

It's Not That Kind Of Party(tm)

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
