From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 27 Jun 2006 20:28:01 +0200
Message-Id: <20060627182801.20891.11456.sendpatchset@lappy>
Subject: [PATCH 0/5] mm: tracking dirty pages -v13
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi,

Hopefully the last version. 
Patches are against mainline again.

The 'big' change since last, is that I added a flags parameter to
vma_wants_writenotify(). These flags allow to skip some tests.
This cleans up the subtlety in mprotect_fixup().

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
