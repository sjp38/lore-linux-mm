Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by sgi.com (980327.SGI.8.8.8-aspam/980304.SGI-aspam:
       SGI does not authorize the use of its proprietary
       systems or networks for unsolicited or bulk email
       from the Internet.)
	via ESMTP id NAA03322
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Mon, 18 Sep 2000 13:46:11 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from madurai.engr.sgi.com (madurai.engr.sgi.com [163.154.5.75])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id NAA89557
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Mon, 18 Sep 2000 13:46:07 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from sgi.com (mango.engr.sgi.com [163.154.5.76]) by madurai.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) via ESMTP id NAA60171 for <linux-mm@kvack.org>; Mon, 18 Sep 2000 13:42:15 -0700 (PDT)
Message-ID: <39C67FA1.89FDCD72@sgi.com>
Date: Mon, 18 Sep 2000 13:48:33 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Test8 performance
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Test8 performance using various benchmarks as compared to previous versions.

Observations
------------

 o test5 continues to yield the best performance.
 o block I/O performance still about 10% slower as compared to test5
 o dbench is still slower compared to test5
 o In test8 reads using larger chunk sizes are sligthly slower.
   Example, reading 1024K at-a-time is ~17.8 MB/s vs. 18.8 Mb/s using
   64K at-a-time.
   
All numbers on a 2P 64MB X86 box using a dedicated scsi disk for the tests
containing an EXT2 filesystem. All tests were run 3 times, in some cases
individual results from 3 runs are reported; in others a range is given.

------
Bonnie
------
              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char-  --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU  K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU

TEST8     256  3597 98.8  10130 14.1  5763 10.8  3324 99.0 17970 19.3 184.8  2.9
TEST8     256  3652 99.9  10099 14.4  5830 11.7  3321 98.6 18099 19.0 185.8  2.7
TEST8     256  3652 100.0 10031 15.4  5745 12.0  3323 98.5 17962 18.9 185.7  2.5

TEST7     256  3593 98.6   9258 13.2  5917 10.5  3052 90.5 18191 16.8 159.6  2.0
TEST7     256  3649 99.9   9149 12.8  6068 10.6  3062 90.5 18178 17.0 165.9  2.9
TEST7     256  3653 100.1  9796 13.6  5983 10.4  3040 90.1 18172 17.7 169.3  2.2

TEST6     256  3624 99.2  10057 14.3  5917 10.3  3031 90.1 18159 18.4 180.6  2.3
TEST6     256  3650 99.9  10096 14.6  5917 10.7  3032 89.9 18143 17.9 185.2  2.3
TEST6     256  3649 100.0 10036 14.2  5894 10.2  3038 90.0 18188 17.4 184.6  2.8

TEST5     256  3618 99.2  11135 16.0  5981 10.8  3005 88.8 18268 17.8 185.4  2.9
TEST5     256  3652 100.0 11066 15.6  6014 10.6  2999 89.1 18276 17.4 185.5  2.8
TEST5     256  3647 99.8  11055 15.8  5924 10.3  3003 88.8 18270 18.5 183.5  3.1
 
 
-----------------------------------
lmdd (across blocksizes 1K to 1024K)
------------------------------------
                 Write            Read
                ---------       --------
TEST8           10.8  MB/s       ~18.8 MB/s [ block sizes 1K -> 256K ]
                                 ~17.8 MB/s [ block sizes 512K,1024K ]
TEST7           10.8  MB/s       ~19   MB/s
TEST6           10.8  MB/s       ~19   MB/s
TEST5           11.5  MB/s       ~19   MB/s
 
-------------------
DBENCH (48 clients)
-------------------
TEST8       8.4, 8.3, 9.2 MB/sec
TEST7       8.7, 9.0, 9.2 MB/sec
TEST6       8.6, 8.1, 7.1 MB/sec
TEST5       11.5 - 12.4   MB/sec

-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
