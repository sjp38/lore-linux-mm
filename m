Date: Tue, 23 May 2006 10:43:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [0/5] sys_move_pages() updates
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

These patches are against 2.6.17-rc4-mm3 and complete
the implementation of sys_move_pages().

1. Fix brokenness in follow_page introduced with the dirty pages patch.

2. Extract common permissions check

3. Fixups sys_move_pages()

4. x86_64 support

5. 32 bit support for i386, x86_64 and ia64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
