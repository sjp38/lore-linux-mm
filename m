From: linux-kernel@vger.kernel.org
Subject: [patch 00/19] VM pageout scalability improvements
Date: Wed, 02 Jan 2008 17:41:44 -0500
Message-ID: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760158AbYABX0q@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-Id: linux-mm.kvack.org

On large memory systems, the VM can spend way too much time scanning
through pages that it cannot (or should not) evict from memory. Not
only does it use up CPU time, but it also provokes lock contention
and can leave large systems under memory presure in a catatonic state.

Against 2.6.24-rc6-mm1

This patch series improves VM scalability by:

1) making the locking a little more scalable

2) putting filesystem backed, swap backed and non-reclaimable pages
   onto their own LRUs, so the system only scans the pages that it
   can/should evict from memory

3) switching to SEQ replacement for the anonymous LRUs, so the
   number of pages that need to be scanned when the system
   starts swapping is bound to a reasonable number

The noreclaim patches come verbatim from Lee Schermerhorn and
Nick Piggin.  I have made a few small fixes to them and left out
the bits that are no longer needed with split file/anon lists.

The exception is "Scan noreclaim list for reclaimable pages",
which should not be needed but could be a useful debugging tool.

-- 
All Rights Reversed

