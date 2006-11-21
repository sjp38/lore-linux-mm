Date: Tue, 21 Nov 2006 12:36:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 0/6] Remove global slab cache declarations from slab.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

One of the strange issues in slab.h is that it contains a list of global
slab caches. The following patches remove all the global definitions from
slab.h into #include <linux/*> files where related information is defined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
