From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Sat, 24 Jun 2006 00:31:03 +0200
Message-Id: <20060623223103.11513.50991.sendpatchset@lappy>
Subject: [PATCH 0/5] mm: tracking dirty pages -v11
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi,

I hope to have addressed all Hugh's latest comments in this version.
Its against 2.6.17-mm1, however I wasted most of the day trying to 
test it on that kernel. But due to various circumstances that failed.

So I've tested something like this against something 2.6.17'ish and 
respun against the -mm lineup.

I've taken Hugh's msync changes too, looks a lot better and does indeed
fix some boundary cases.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
