Received: from mail.inconnect.com (mail.inconnect.com [209.140.64.7])
	by kvack.org (8.8.7/8.8.7) with SMTP id BAA09598
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 01:28:29 -0500
Date: Fri, 8 Jan 1999 23:28:16 -0700 (MST)
From: Dax Kelson <dkelson@inconnect.com>
Subject: 2.2.0-pre[56] swap performance poor with > 1 thrashing task
In-Reply-To: <87iueiudml.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.4.04.9901082246490.1183-100000@brookie.inconnect.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On 7 Jan 1999, Zlatko Calusic wrote:

> 2.2.0-pre5 works very good, indeed, but it still has some not
> sufficiently explored nuisances:
> 
> 1) Swap performance in pre-5 is much worse compared to pre-4 in
> *certain* circumstances. I'm using quite stupid and unintelligent
> program to check for raw swap speed (attached below). With 64 MB of
> RAM I usually run it as 'hogmem 100 3' and watch for result which is
> recently around 6 MB/sec. But when I lately decided to start two
> instances of it like "hogmem 50 3 & hogmem 50 3 &" in pre-4 I got 2 x
> 2.5 MB/sec and in pre-5 it is only 2 x 1 MB/sec and disk is making
> very weird and frightening sounds. My conclusion is that now (pre-5)
> system behaves much poorer when we have more than one thrashing
> task. *Please*, check this, it is a quite serious problem.

I just tried this on 2.2.0-pre6 PentiumII 412Mhz, 128MB SDRAM, one IDE
disk (/ & swap).

./hogmem 100 3  (no swapping)
Memory speed: 167.60 MB/sec

./hogmem 200 3
Memory speed: 9.01 MB/sec

./hogmem 100 3 & ./hogmem 100 3
Memory speed: 0.96 MB/sec
Memory speed: 0.96 MB/sec

./hogmem 100 3 (no swap)
Memory speed: 180.18 MB/sec

./hogmem 200 3
Memory speed: 8.68 MB/sec

I then tried 

./hogmem 200 3 &

find / (on about 1.5GB of data on ext2 and vfat and nfs repeatedly) 

And launched netscape.  After 45 mins, I didn't restart the find, and
about 3 mins later the hogmem completed at 0.75MB/sec.  Netscape was
surprisingly responsive however.

Dax Kelson



--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
