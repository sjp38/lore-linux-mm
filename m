From: Andi Kleen <ak@suse.de>
Subject: Re: NFS: Unable to handle kernel NULL pointer dereference at nfs_set_page_dirty+0xd/0x5d in 2.6.21rc7-git6
Date: Tue, 24 Apr 2007 20:19:11 +0200
References: <200704241605.45353.ak@suse.de> <1177441075.5498.6.camel@heimdal.trondhjem.org>
In-Reply-To: <1177441075.5498.6.camel@heimdal.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704242019.11983.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Does this patch fix it?

Didn't hit that particular oops with that anymore in several LTP runs and
your patch applied, but got this data corruption:

doio(rwtest04) (20172) 19:01:03
---------------------
*** DATA COMPARISON ERROR ***
check_file(/tmp/ltp-14369/mm-sync-20156, 12754624, 23879, R:20172:bigfoot:doio*,
 21, 0) failed

Comparison fd is 5, with open flags 0
Corrupt regions follow - unprintable chars are represented as '.'
-----------------------------------------------------------------
corrupt bytes starting at file offset 12754624
    1st 32 expected bytes:  R:20172:bigfoot:doio*R:20172:big
    1st 32 actual bytes:    ................................

Request number 622
          fd 4 is file /tmp/ltp-14369/mm-sync-20156 - open flags are 010002 O_RD
WR,O_SYNC,
          write done at file offset 12754624 - pattern is R (0122)
          number of requests is 1, strides per request is 1
          i/o byte count = 23879
          memory alignment is unaligned

syscall:  mmap-write(NULL, 12800000, PROT_WRITE, MAP_SHARED, 4, 0)
        file is mmaped to: 0x2b982c7ca000
        file-mem=0x2b982d3f3ec0, length=23879, buffer=0x52d543


doio(rwtest04) (20169) 19:01:03
---------------------
(parent) pid 20172 exited because of data compare errors


To reproduce: run runltplite.sh of LTP over NFS a few times

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
