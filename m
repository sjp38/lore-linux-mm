Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by sgi.com (980327.SGI.8.8.8-aspam/980304.SGI-aspam:
       SGI does not authorize the use of its proprietary
       systems or networks for unsolicited or bulk email
       from the Internet.)
	via ESMTP id LAA02973
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Sun, 20 Aug 2000 11:54:23 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from madurai.engr.sgi.com (madurai.engr.sgi.com [163.154.5.75])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id LAA79699
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Sun, 20 Aug 2000 11:54:23 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from sgi.com (sgigate.sgi.com [198.29.75.75]) by madurai.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) via ESMTP id LAA22116 for <linux-mm@kvack.org>; Sun, 20 Aug 2000 11:50:41 -0700 (PDT)
Message-ID: <39A02880.54E3C08@sgi.com>
Date: Sun, 20 Aug 2000 11:50:40 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Performance: test6, 7-5, 7-5 Multiqueue, history
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Another performance update using various benchmarks. In the following,
TEST7-5 is test7-pre5 patch. TEST7-5MQ has in addition
the Multiqueue VM patch (the MQ patch is 2.4.0-t7p4-vmpatch2b,
dated circa Tue Aug 15 14:27:14 2000).

Observations
------------

 o test5 continues to yield the best performance.
 o test5 -> test6 (and in test7-5) block I/O performance degraded about 10%.
 o test6 -> test7-5 non-streaming dbench performance stabilized.
 o considering best results in each kernel version,
   both test6 & test7-5 are worse than test5 by about 30%
 o MQ patch yields bad performance in most cases; perhaps changes
   between test7-pre4 and test7-pre5 don't sit well with MQ changes,
   since I used the t7p4 MQ patch.

All numbers on a 2P 64MB X86 box using a dedicated scsi disk for the tests
containing an EXT2 filesystem. All tests were run 3 times, in some cases
individual results from 3 runs are reported; in others a range is given.

------
Bonnie
------
              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char-  --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU  K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU

TEST7-5MQ 256  3507 97.1   9021 14.3  3715  6.6  2985 88.6 16494 17.7 170.8  2.4
TEST7-5MQ 256  3572 98.9   9153 14.1  3757  7.1  2984 88.1 15749 17.7 170.0  2.5
TEST7-5MQ 256  3566 98.3   9086 13.7  3776  6.8  2975 88.5 16469 16.7 171.4  2.8

TEST7-5   256  3651 100.1 10041 14.4  5916 11.1  3038 89.9 18153 17.5 187.0  3.4
TEST7-5   256  3649 100.0 10105 14.1  5931 10.6  3034 89.8 18155 18.4 187.7  2.5
TEST7-5   256  3651 99.9  10077 14.7  5923 10.7  3041 89.9 18184 17.6 187.9  2.6

TEST6     256  3624 99.2  10057 14.3  5917 10.3  3031 90.1 18159 18.4 180.6  2.3
TEST6     256  3650 99.9  10096 14.6  5917 10.7  3032 89.9 18143 17.9 185.2  2.3
TEST6     256  3649 100.0 10036 14.2  5894 10.2  3038 90.0 18188 17.4 184.6  2.8

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
lmdd (across blocksizes 1K to 1024K)
------------------------------------
                 Write            Read
                ---------       --------
TEST7-5+MQ      9.4-10.4 MB/s   15.5-17 MB/sec
TEST7-5         10.8  MB/s       ~19   MB/s
TEST6           10.8  MB/s       ~19   MB/s
TEST5           11.5  MB/s       ~19   MB/s
TEST4           10    MB/s      [ Didn't run this ]
TEST3           10-11 MB/s       ~19   MB/s
TEST1           6-7   MB/s       ~18.5 MB/s
 
-------------------
DBENCH (48 clients)
-------------------
TEST7-5+MQ  2.7, 2.7, 1.9 MB/sec
TEST7-5     8.4, 8.6, 8.8 MB/sec
TEST6       8.6, 8.1, 7.1 MB/sec
TEST5       11.5 - 12.4   MB/sec
TEST4       10.X - 11.X   MB/sec
TEST3       10.X - 11.X   MB/sec
TEST1        1.5 -  2.X   MB/sec


-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
