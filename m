Date: Sun, 21 Jul 2002 04:14:51 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: [PATCH 1/2][CFT] Full rmap VM for 2.5.27
Message-ID: <Pine.LNX.4.44.0207210218410.6770-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


A new release of the full-featured rmap patch (Rik van Riel's rmap-13b) is 
available against the minimal rmap in 2.5.27.  This first patch brings the 
2.5 VM into approximate parity with 2.4-ac in terms of basic page 
replacement, page aging, and lru list logic.  

A description from the last posting:  
	http://mail.nl.linux.org/linux-mm/2002-07/msg00215.html


Changelog:
- Sync'ed with the 2.5.27 rmap merge
- Added Bill Irwin's recent patch that converts the pte_chain freelist to 
  use mempool.  Updated VM stats.  A nice patch that seems to work well 
  here, so far... :)


Next release:
- multi-page batch processing of the list-scanning methods in 
  vmscan to reduce lock contention, ala Andrew Morton's recent patches
- looking into 2.4-aa for useful tidbits
- various rmap updates from the usual suspects... :)


Get it here:
	http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/2.5.27/


Try it, use it, send feedback. :)

Craig Kulesa
Steward Observatory
Univ. of Arizona

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
