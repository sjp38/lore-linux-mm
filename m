Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by sgi.com (980327.SGI.8.8.8-aspam/980304.SGI-aspam:
       SGI does not authorize the use of its proprietary
       systems or networks for unsolicited or bulk email
       from the Internet.)
	via ESMTP id LAA03366
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Fri, 28 Jul 2000 11:50:18 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from madurai.engr.sgi.com (madurai.engr.sgi.com [163.154.5.75])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id LAA03031
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Fri, 28 Jul 2000 11:50:17 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from sgi.com (mango.engr.sgi.com [163.154.5.76]) by madurai.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) via ESMTP id LAA95522 for <linux-mm@kvack.org>; Fri, 28 Jul 2000 11:46:42 -0700 (PDT)
Message-ID: <3981D643.5C2EC40A@sgi.com>
Date: Fri, 28 Jul 2000 11:51:47 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Test5 performance comparison
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In short, test5 looks good, the best ever
in my experience. In detail:

All numbers on a 2P 64MB X86 box using
a dedicated scsi disk for the tests containing
an EXT2 filesystem.

------
Bonnie
------
              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
 Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU            

TEST5     256  3618 99.2  11135 16.0  5981 10.8  3005 88.8 18268 17.8 185.4  2.9
TEST5     256  3652 100.0 11066 15.6  6014 10.6  2999 89.1 18276 17.4 185.5  2.8
TEST5     256  3647 99.8  11055 15.8  5924 10.3  3003 88.8 18270 18.5 183.5  3.1
 
TEST4     256  3630 99.5   9915 14.7  6013 11.3  2894 86.0 18502 19.1 181.4  3.1
TEST4     256  3110 85.5   9884 14.7  6098 11.1  1831 54.3 18554 17.6 183.8  3.0
TEST4     256  3301 89.7   9857 15.3  6034 10.2  2772 82.7 18570 17.6 180.8  2.5
 
TEST3     256  3628 99.5  10693 15.3  6084 10.7  3014 89.5 18533 17.7 182.6  3.2
TEST3     256  3648 100.2 10456 15.2  6044 11.1  3031 89.7 18511 18.6 183.6  2.5
TEST3     256  3650 99.9  10545 15.6  6046 10.8  3020 89.9 18518 19.8 181.6  2.6
 
TEST1     256  3434 94.8   6858 12.0  2949  6.1  3110 93.0 18713 21.3 174.9  3.3
TEST1     256  3421 95.0   6933 11.2  2628  6.0  3052 91.2 18569 22.0 176.0  2.5
TEST1     256  3474 96.5   6900 11.5  2824  6.1  3023 90.6 18103 24.4 173.5  2.9
 
 
-----------------------------------
lmdd (across blocksizes 1K to 1024K
------------------------------------
                Write           Read
               ---------        --------
TEST5           11.5  MB/s      ~19MB/s
TEST4           10    MB/s      [ Didn't run this ]
TEST3           10-11 MB/s      ~19MB/s
TEST1            6-7  MB/s      ~18.5MB/s
 
-------------------
DBENCH (48 clients)
-------------------
TEST5 - 11.5 - 12.4 MB/sec
TEST4 - 10.X - 11.X  MB/sec
TEST3 - 10.X - 11.X  MB/sec
TEST1 -  1.5 -  2.X  MB/sec
                                                                       


-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
