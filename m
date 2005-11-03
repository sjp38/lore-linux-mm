Subject: Clock-Pro
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain
Date: Thu, 03 Nov 2005 23:15:22 +0100
Message-Id: <1131056122.18825.173.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Song Jiang <sjiang@lanl.gov>
Cc: Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Song Jiang,


I implemented the things I talked about, they can be found here:
  http://programming.kicks-ass.net/kernel-patches/clockpro/

However I have the strong feeling I messed up the approximation, hence I
have tried to extract a state table for the original algorithm from the
paper but I find some things not quite obvious. Could you help me
complete this thing:


res | h/c | tst | ref || Hcold | Hhot | Htst || Flt
----+-----+-----+-----++-------+------+------++-----
 0  |  0  |  0  |  1  ||       |      |      || 1010
 0  |  0  |  1  |  0  ||=0010  |  X   |  X   || 
 0  |  0  |  1  |  1  ||       |      |      || 1100
 1  |  0  |  0  |  0  ||  X    |  X   |=1000 ||
 1  |  0  |  0  |  1  || 1000  | 100? | 100? ||
 1  |  0  |  1  |  0  ||=1010  | 0010 | 1000 ||
 1  |  0  |  1  |  1  || 1100  | 101? | 100? ||
 1  |  1  |  0  |  0  ||=1100  | 10?0 |=1100 || 
 1  |  1  |  0  |  1  || 110?  | 1100 | 110? || 


res := resident
h/c := hot/cold
tst := test period
ref := referenced

H* := resulting state after specified hand passed,
      where prefix '=' designated no change and
      'X' designates remove from list.

      '?' are uncertain, please help.

Flt := pagefault column; nonresident and referenced.
       state after fault.


Kind regards,

Peter Zijlstra

-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
