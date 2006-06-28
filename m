From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 28 Jun 2006 22:17:02 +0200
Message-Id: <20060628201702.8792.69638.sendpatchset@lappy>
Subject: [PATCH 0/6] mm: tracking dirty pages -v14
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi,

Hopefully the last version (again!).

Hugh really didn't like my vma_wants_writenotify() flags, so I took
them out again.

Also added another patch to the end that corrects the do_wp_page()
COWing of anonymous pages.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
