Date: Tue, 25 Apr 2000 14:20:19 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
In-Reply-To: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Simon Kirby <sim@stormix.com>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Andrea Arcangeli wrote:
> On Tue, 25 Apr 2000, Rik van Riel wrote:
> 
> >If you look closer, you'll see that none of the swapped out
> >stuff is swapped back in again. This shows that the VM
> >subsystem did make the right choice here...
> 
> Swapping out with 50mbyte of cache isn't the right choice unless
> all the 50mbyte of cache were mapped in memory (and I bet that
> wasn't the case).

Funny you just state this without explaining why.
If the memory that's swapped out isn't used again
in the next 5 minutes, but the pages in the file
cache _are_ used (eg. for compiling that kernel you
just unpacked), then it definately is the right
choice to keep the cached data in memory and swap
out some part of netscape.

regards,

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
