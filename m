Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005102204370.1155-100000@penguin.transmeta.com>
From: "James H. Cloos Jr." <cloos@jhcloos.com>
In-Reply-To: Linus Torvalds's message of "Wed, 10 May 2000 22:10:13 -0700 (PDT)"
Date: 11 May 2000 05:09:48 -0500
Message-ID: <m3og6d4cur.fsf@austin.jhcloos.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Tried the cp of the compiled kernel tree on 7-9.  *Much* better than any of
the 99s I've tried.  On the 4k ext2 ide drive:

    # time cp -av linux-2.3.99-pre7-9 L
    [...]
    0.81user 8.95system 3:37.76elapsed 4%CPU (0avgtext+0avgdata 0maxresident)k
    0inputs+0outputs (158major+199minor)pagefaults 0swaps
    # time du -s L
    137404  L
    0.05user 0.42system 0:05.41elapsed 8%CPU (0avgtext+0avgdata 0maxresident)k
    0inputs+0outputs (105major+26minor)pagefaults 0swaps

kswapd did hit a peak of 50% cpu, but only *very* briefly; it hovered
in the 5% to 10% range for most of the 218 seconds.

On the 1k ext2 scsi drive, kswapd never exceeded 25% cpu, though the
cp took about twice as long for 2/3 the data (and no -v switch):

    # time cp -a linux-2.3.99-pre7-8/ L 
    0.26user 6.80system 5:57.71elapsed 1%CPU (0avgtext+0avgdata 0maxresident)k
    0inputs+0outputs (141major+180minor)pagefaults 0swaps
    # time du -s L
    88545   L
    0.02user 0.59system 0:03.82elapsed 15%CPU (0avgtext+0avgdata 0maxresident)k
    0inputs+0outputs (105major+23minor)pagefaults 0swaps

Mem usage seems to be about 2:1 in favour of cache+buffer.

Another usefule test I've found is to run realplay on large streams.
mediatrip.com has some useful ones, OTOO 22 minutes at 700 kbps.
Watching the four or five such streams which make up a given film in
the same realplay session will result in a segfault in any of the
previous 99s.  At least if you watch the 700 kbps streams at double
resolution.  That combo seems to have enough memory pressure.  

I'd suggest someone w/ more bandwidth than my workstation try it, though.

-JimC
-- 
James H. Cloos, Jr.  <URL:http://jhcloos.com/public_key> 1024D/ED7DAEA6 
<cloos@jhcloos.com>  E9E9 F828 61A4 6EA9 0F2B  63E7 997A 9F17 ED7D AEA6
     Check out TGC:  <URL:http://jhcloos.com/go?tgc>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
