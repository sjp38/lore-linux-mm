Message-ID: <3F0EBCC1.60106@aitel.hist.no>
Date: Fri, 11 Jul 2003 15:33:53 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.75-mm1 nfs trouble
References: <20030711022952.21c98720.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

2.5.75mm1 has nfs trouble I don't see in 2.5.74mm3.

It works for a while, then all file operations
on the nfs mount gets stuck.

dmesg is then full of stuff like this:
  Jul 11 13:12:16 hh kernel: nfs: server hermine.idb.hist.no not 
responding, still trying
Jul 11 13:12:17 hh kernel: nfs: server hermine.idb.hist.no OK
Jul 11 13:13:25 hh kernel: nfs: server hermine.idb.hist.no not 
responding, still trying
Jul 11 13:13:25 hh kernel: nfs: server hermine.idb.hist.no OK
Jul 11 13:13:31 hh kernel: nfs: server hermine.idb.hist.no not 
responding, still trying
Jul 11 13:13:31 hh kernel: nfs: server hermine.idb.hist.no OK
Jul 11 13:13:31 hh kernel: nfs: server hermine.idb.hist.no not 
responding, still trying
Jul 11 13:13:31 hh kernel: nfs: server hermine.idb.hist.no OK
Jul 11 13:13:32 hh kernel: nfs: server hermine.idb.hist.no not 
responding, still trying
Jul 11 13:13:32 hh kernel: nfs: server hermine.idb.hist.no not 
responding, still trying
Jul 11 13:13:32 hh kernel: nfs: server hermine.idb.hist.no OK
Jul 11 13:13:32 hh kernel: nfs: server hermine.idb.hist.no OK
Jul 11 13:13:32 hh kernel: nfs: server hermine.idb.hist.no not 
responding, still trying
.
. several pages
.
Jul 11 15:11:49 hh kernel: nfs: server hermine.idb.hist.no OK
Jul 11 15:11:49 hh kernel: nfs: server hermine.idb.hist.no not 
responding, still trying
Jul 11 15:11:51 hh kernel: eth0: Transmit error, Tx status register 82.
Jul 11 15:11:51 hh kernel: Probably a duplex mismatch.  See 
Documentation/networking/vortex.txt
Jul 11 15:11:51 hh kernel:   Flags; bus-master 1, dirty 49353(9) current 
49365(5)
Jul 11 15:11:51 hh kernel:   Transmit list 1fde6b60 vs. dfde67a0.
Jul 11 15:11:51 hh kernel:   0: @dfde6200  length 800005ea status 000005ea
Jul 11 15:11:51 hh kernel:   1: @dfde62a0  length 800005ea status 000005ea
Jul 11 15:11:51 hh kernel:   2: @dfde6340  length 800005ea status 000005ea
Jul 11 15:11:51 hh kernel:   3: @dfde63e0  length 800005ea status 000005ea
Jul 11 15:11:51 hh kernel:   4: @dfde6480  length 800003ba status 800003ba
Jul 11 15:11:51 hh kernel:   5: @dfde6520  length 800005ea status 000105ea
Jul 11 15:11:51 hh kernel:   6: @dfde65c0  length 800005ea status 000105ea
Jul 11 15:11:51 hh kernel:   7: @dfde6660  length 800005ea status 000105ea
Jul 11 15:11:51 hh kernel:   8: @dfde6700  length 800003ba status 000103ba
Jul 11 15:11:51 hh kernel:   9: @dfde67a0  length 800005ea status 000105ea
Jul 11 15:11:51 hh kernel:   10: @dfde6840  length 800005ea status 000105ea
Jul 11 15:11:51 hh kernel:   11: @dfde68e0  length 800005ea status 000105ea
Jul 11 15:11:51 hh kernel:   12: @dfde6980  length 800005ea status 000105ea
Jul 11 15:11:51 hh kernel:   13: @dfde6a20  length 800005ea status 000105ea
Jul 11 15:11:51 hh kernel:   14: @dfde6ac0  length 800003ba status 000103ba
Jul 11 15:11:51 hh kernel:   15: @dfde6b60  length 800005ea status 000005ea
.
.This block repeats over a few pages
.
Jul 11 15:15:46 hh kernel: RPC: sendmsg returned error 101
Jul 11 15:15:46 hh kernel: nfs: RPC call returned error 101
Jul 11 15:15:46 hh kernel: RPC: sendmsg returned error 101
Jul 11 15:15:46 hh kernel: nfs: RPC call returned error 101
Jul 11 15:15:46 hh kernel: RPC: sendmsg returned error 101
.
. several pages
.
At some point I managed to get my waiting processes "unstuck"
by "ifdown eth0" followed by "ifup eth0"  They all failed
with network unreachable and I saved files to a local disk.

I then tried some simple copying on the still
mounted nfs, and it got stuck again pretty fast.
I then rebooted into 2.5.74mm3 because I need to work.
I won't be able to test much until monday.

The machine is UP, and uses preempt.
The distribution is debian testing
The nfs mount uses the following options:
   rsize=8192,wsize=8192,user,noauto,hard,intr

Helge Hafting



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
