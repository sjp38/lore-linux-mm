Date: Mon, 5 Feb 2007 12:52:35 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 0/7] Move mlocked pages off the LRU and track them
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[RFC] Remove mlocked pages from the LRU and track them

The patchset removes mlocked pages from the LRU and maintains a counter
for the number of discovered mlocked pages.

This is a lazy scheme for accounting for mlocked pages. The pages
may only be discovered to be mlocked during reclaim. However, we attempt
to detect mlocked pages at various other opportune moments. So in general
the mlock counter is not far off the number of actual mlocked pages in
the system.

Patch against 2.6.20-rc6-mm3

Known problems to be resolved:
- Page state bit used to mark a page mlocked is not available on i386 with
  NUMA.
- Note tested on SMP, UP. Need to catch a plane in 2 hours.

Tested on:
IA64 NUMA 12p

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
