From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 0/7] Move mlocked pages off the LRU and track them V1
Date: Wed, 14 Feb 2007 17:24:49 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[PATCH Remove mlocked pages from the LRU and track them V1

The patchset removes mlocked pages from the LRU and maintains a counter
for the number of discovered mlocked pages.

This is a lazy scheme for accounting for mlocked pages. The pages
may only be discovered to be mlocked during reclaim. However, we attempt
to detect mlocked pages at various other opportune moments. So in general
the mlock counter is not far off the number of actual mlocked pages in
the system.

Patch against 2.6.20-git9

Changes: RFC->V1
- Fixup a series of issues: PageActive handling, page migration etc.
- Tested on SMP and UP.

Tested on:
- IA64 NUMA 12p
- x86_64 NUMA emulation
- x86_64 SMP
- x86_64 UP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
