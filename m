From: David Kulp <dkulp@neomorphic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14314.28197.161697.652050@verona.neomorphic.com>
Date: Thu, 23 Sep 1999 11:15:01 -0700 (PDT)
Subject: oom - out of memory
In-Reply-To: <19990920153512.A20067@alna.lt>
References: <19990920153512.A20067@alna.lt>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kestutis Kupciunas <kesha@soften.ktu.lt>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

I have just the same problem with the same kernels: system hangs when
one process requires more than total RAM.  I can't kill processes or
otherwise get any response.  No syslog messages.  I don't know where
to start to try to track down this problem -- but I thought monitoring
this list would be a start.  Ironically -- considering the recent
'ammo' thread, I had no trouble with this in FreeBSD.    )-:

If someone needs specific reproducible test cases or other details,
I'd love to try and help.

-d

ps. This isn't an X problem as could possibly be hypothesized from the 
original post: this occurs when running non-X apps, too.

Kestutis Kupciunas writes:
 > hello, linux memory managers,
 > 
 > thing i am eager to clarify is oom, out of memory problem,
 > which doesn't work as it is supposed to (at least i think it
 > doesn't do the trick). Having the system fully utilizing all the
 > memory available on box and requesting more simply "hangs"
 > the box. 
 > Going into more details: i have noticed this behavior
 > with all 2.[23].x kernels i have used (not sure about the previous series).
 > usually problem arises when manipulating LARGE sets of large images
 > under X (with gimp, imagemagick tools). as i open more images, naturally,
 > memory/swap usage grows, and when it grows to the bounds, keyboard stops
 > responding, screen stops repainting, hdd led's going crazy. all box
 > services stop responding - i'm unable to connect from remote box. *RESET* :(
 > this behavior isnt my box specific - i've vitnessed it happening on
 > a bunch of different intels as well. The only chracteristics that apply
 > to all those boxes are that all of them are x86.
 > but according to the oom() function, the pid which is requesting
 > memory when it's out, is beeing killed with a message.
 > i didnt find any message in logs later...
 > im not a 'kernel hacker', so maybe somebody could analyze the lifecycle
 > of linux-mm memory allocating up to the bounds and over?
 > or is there something i don't get right?
 > sorry for the messy english
 > 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
