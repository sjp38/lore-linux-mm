Date: Tue, 28 Nov 2006 16:44:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 0/8] Slab: Remove GFP_XX aliases from slab.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

slab.h contains a series of definitions that are simply aliases
for gfp_XX. This duplication makes it difficult to search for uses
of f.e. GFP_ATOMIC. Strange mixtures of uses of __GFP_xx with SLAB_xx
exist in some pieces of code.

This patchset removes all the aliases from slab.h and also removes all
occurrences.

I have tried to order these by size so that it is possible to just take the
first few of these patches should they be considered to be too complex.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
