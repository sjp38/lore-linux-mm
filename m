Subject: Re: classzone-VM + mapped pages out of lru_cache
References: <Pine.LNX.4.21.0005031813040.489-100000@alpha.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Wed, 3 May 2000 18:26:19 +0200 (CEST)"
Date: 04 May 2000 16:40:24 +0200
Message-ID: <yttu2gel6p3.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

Hi

andrea> It gives me smoother swap behaviour since the swap cache hardly pollutes
andrea> the lru_cache now.

Andrea I have run here last night your patch (classzone-18) against
pre7-3 in one machine and vanilla pre7-3 in other machine.  The test
was from my memtest suite: 
    while (true); do time ./mmap002; done
suited to the memory of my system (Uniprocessor 96MB)

The results are very good for your patch:

Vanilla pre7-3            pre7-3+classzone-18
real    3m29.926s         real    2m10.210s
user    0m15.280s         real    2m10.210s
sys     0m20.500s         real    2m10.210s

That are the normal times. classzone patches variations are very low
(all the iterations are between 2m08 and 2m10).  But in vanilla
pre7-3, the variations are higher: between 3m4 and 4m20, and the worst
part, when the kswapd problem appear, the program takes until  36m20
(yes 36, ten times more, is not a typo).  Furthermore, vanilla pre7-3
kill the process after 2 hours and a half,  classzone works for more
than 12 hours without a problem.

That is the description of the situation.  Andrea, why do you reverse
the patch of filemap.c:truncate_inode_pages() of using TryLockPage()?
That change was proposed by Rik due to an Oops that I get here.  It
was one of the non-easily reproducible ones that I get.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
