From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906141717.KAA31065@google.engr.sgi.com>
Subject: Re: process selection
Date: Mon, 14 Jun 1999 10:17:27 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.03.9906122156290.534-100000@mirkwood.nl.linux.org> from "Rik van Riel" at Jun 12, 99 10:00:30 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Could it be an idea to take the 'sleeping time' of each
> process into account when selecting which process to swap
> out?  Due to extreme lack of free time, I'm asking what
> you folks think of it before testing it myself...
>

You are right, sleep time is a good heuristic to determine 
the "swappability" of a process. 

Hmm, I wonder if this is what happended in your case: setiathome
probably had a big rss, but netscape and X probably had 
larger rss and got selected for stealing. 

These are just a couple of things probably worth trying out:
1. The stealing algorithm can be upgraded to steal more than just
SWAP_CLUSTER_MAX, for all the work it does.
2. Also, in swap_out, it might make sense to steal more than a
single page from a victim process, to balance the overhead of
scanning all the processes.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
