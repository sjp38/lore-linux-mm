Received: from toomuch.toronto.redhat.com (IDENT:bcrl@toomuch.toronto.redhat.com [172.16.14.22])
	by devserv.devel.redhat.com (8.11.0/8.11.0) with ESMTP id f844QYO21779
	for <linux-mm@kvack.org>; Tue, 4 Sep 2001 00:26:34 -0400
Date: Tue, 4 Sep 2001 00:26:33 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: pmap revisited (fwd)
Message-ID: <Pine.LNX.4.33.0109040026270.2726-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


-- 
"The world would be a better place if Larry Wall had been born in
Iceland, or any other country where the native language actually
has syntax" -- Peter da Silva

---------- Forwarded message ----------
Date: Tue, 4 Sep 2001 03:13:34 +0000 (UTC)
From: Samium Gromoff <_deepfire@mail.ru>
To: linux-kernel@vger.kernel.org
Cc: marcelo@brutus.conectiva.com.br, riel@surriel.com
Subject: pmap revisited

             Ashes on my head guys...
    Gotta wrong results in my previous perftest... (slightly different
  environments), so these are to be sure that on low VM load there isnt
  any significant difference...

  Here are new and revisited. Actually i maked sure that the environments
differs only in kernels...

  Bonus: two bugs! :)
   1. Quintela`s (shmtest of memtest) and pmap{2,3} == 100% instant deadlock
      plain ac12 demonstrates ignorance.
   2. Swapoff oops 100% - only in pmap3! (okay, swapoff of reiserfs
      to be strict, but i think that doesnt actually matters)
      swapoff oops will be in next mail.

  Revisited results:

time find / -xdev - done 5 times
pmap 3
real    1m5.175s
real    1m4.699s
real    1m3.579s
============================
pmap 2
real    1m5.039s
real    1m4.779s
real    1m4.506s
============================
plain
real    1m4.820s
real    1m4.433s
real    1m4.285s

* fillmem == (fillmem of memtest)
* dont count on differences - they are quite flaky, one is only known:
  there are no much difference anyways...
time fillmem - done 7 times, still giving strange results sometimes...
pmap 3
real    1m2.709s
real    1m2.417s
real    1m1.371s
real    1m1.241s
real    1m0.235s
(1m3.~, 1m4.5~) - add results
============================
pmap 2
real    1m5.294s
real    1m5.169s
real    1m4.431s
real    1m3.878s
real    1m3.523s
(1m6.~, 1m0.~, 1m3.355) - add results
============================
plain
real    1m1.570s
real    1m1.063s
real    1m1.007s
real    1m0.201s
real    0m59.677s

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
