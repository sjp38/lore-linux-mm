Date: Wed, 26 Apr 2000 10:46:03 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
In-Reply-To: <200004261125.EAA12302@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0004261041420.16202-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, sim@stormix.com, jgarzik@mandrakesoft.com, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Wed, 26 Apr 2000, David S. Miller wrote:

> I have to be quite frank, and say that the FreeBSD people are
> pretty much on target when they say that our swapping and paging
> stinks, it really does.

Hehe ;)

> I am of the opinion that vmscan.c:swap_out() is one of our
> biggest problems, because it kills us in the case where a few
> processes have a pagecache page mapped, haven't accessed it in a
> long time, and swap_out doesn't unmap those pages in time for
> the LRU shrink_mmap code to fully toss it.

Please take a look at the patch I sent to the list a few
minutes ago. The "anti-hog" code, using swap_out() as a
primary mechanism for achieving its goal, seems to bring
some amazing results ... for one, memory hogs no longer
have a big performance impact on small processes.

I believe that it will be pretty much impossible to achieve
"fair" balancing with any VM code which weighs all pages the
same. And before you start crying that all pages should be
weighed the same to protect the performance of that important
memory hogging server process, the fact that it'll be the only
process waiting for disk and that its pages are aged better
often make the memory hog run faster as well! ;)

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
