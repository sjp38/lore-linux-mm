Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005090844050.1100-100000@penguin.transmeta.com>
From: "James H. Cloos Jr." <cloos@jhcloos.com>
In-Reply-To: Linus Torvalds's message of "Tue, 9 May 2000 08:44:43 -0700 (PDT)"
Date: 09 May 2000 23:05:01 -0500
Message-ID: <m3snvrvymq.fsf@austin.jhcloos.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "Linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Linus> Try out the really recent one - pre7-8. So far it hassome good
Linus> reviews, and I've tested it both on a 20MB machine and a 512MB
Linus> one..

pre7-8 still isn't completely fixed, but it is better than pre6.

Try doing something like 'cp -a linux-2.3.99-pre7-8 foobar' and
watching kswapd in top (or qps, el al).  On my dual-proc box, kswapd
still maxes out one of the cpus.  Tar doesn't seem to show it, but
bzcat can get an occasional segfault on large files.

The filesystem, though, has 1k rather than 4k blocks.  Yeah, just
tested again on a fs w/ 4k blocks.  kswapd only used 50% to 65% of a
cpu, but that was an ide drive and the former was on a scsi drive.[1]

OTOH, in pre6 X would hit (or at least report) 2^32-1 major faults
after only a few hours of usage.  That bug is gone in pre7-8.

[1] asus p2b-ds mb using onboard adaptec scsi and piix ide; drives are
    all IBM ultrastars and deskstars.

-JimC
-- 
James H. Cloos, Jr.  <URL:http://jhcloos.com/public_key> 1024D/ED7DAEA6 
<cloos@jhcloos.com>  E9E9 F828 61A4 6EA9 0F2B  63E7 997A 9F17 ED7D AEA6
        Save Trees:  Get E-Gold! <URL:http://jhcloos.com/go?e-gold>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
