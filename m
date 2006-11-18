Date: Fri, 17 Nov 2006 21:43:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 0/7] Remove slab cache declarations in slab.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

One of the strange issues in include/linux/slab.h that it contains
a list of global slab caches. The following patches remove all the global
definitions from slab.h and find other ways of defining these caches.

6 of the 7 defined caches are rarely used. One is never used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
