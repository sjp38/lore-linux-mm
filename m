Received: from student.kuleuven.ac.be (kervel@localhost.localdomain [127.0.0.1])
	by uterpe.linux.student.kuleuven.ac.be (8.9.3/8.9.3) with ESMTP id WAA00324
	for <linux-mm@kvack.org>; Mon, 5 Jun 2000 22:00:02 +0200
Message-ID: <393C06BE.E335574@student.kuleuven.ac.be>
Date: Mon, 05 Jun 2000 21:59:59 +0200
From: Frank Dekervel <frank.dekervel@student.kuleuven.ac.be>
MIME-Version: 1.0
Subject: linux 2.4.0test1ac8+riels patch performs okay
Content-Type: multipart/mixed;
 boundary="------------C505CA650D859D8EAB0A511C"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------C505CA650D859D8EAB0A511C
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

hello,

just a little message about my positive experiences with ac8 + riels
patch (i didnot test without):

-> for the io performance it is the fastest development kernel i yet
tested. (got 6meg/sec where raw ac7 gave me about
     the half). this closely matches 2.2

-> it is much more responsive than any other development kernels i have
tested. offcourse this may be a bit subjective.
     even when under high load (eg starting netscape or soffice under
kde) my system stays responsive enough to
     continue working. This was not the case with ac7.

-> my collection of legal mp3's finally plays fluently !! woo hoo !


no need to say it survives the memtest suite.

keep on and thanks for the good work ...

kervel

PS

other kernels i tested :
ac7
ac7 + rogerL's patch
ac7 + riel #1 + rogerL's (crashed)
ac7 + riel #1
(ac8 + riels)

here is a vmstat of a mmap001 .. don't know it its of much use




--------------C505CA650D859D8EAB0A511C
Content-Type: text/plain; charset=us-ascii;
 name="mmap001.vmstat"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mmap001.vmstat"

   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  0  0  21304   2988    308  18920  29  31   360    51  523   182   8   7  85
 0  0  0  21304   2960    308  18932   2   0     2     0  127   122   2   0  98
 1  6  2  21240    380    224  23440 619 422  1004  2240 5089   712   6  12  82
 1  4  0  21316    628    320  22036 530   0   881  4502 11796  1092   1   7  91
 0  0  0  21300  14140    320   8492  69   0   151     0  381   101   1   6  94

--------------C505CA650D859D8EAB0A511C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
