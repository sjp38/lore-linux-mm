From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 25 May 2006 15:55:34 +0200
Message-Id: <20060525135534.20941.91650.sendpatchset@lappy>
Subject: [PATCH 0/3] mm: tracking dirty pages -v5
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

I hacked up a new version last night.

Its now based on top of David's patches, Hugh's approach of using the
MAP_PRIVATE protections instead of the MAP_SHARED seems far superior indeed.

Q: would it be feasable to do so for al shared mappings so we can remove
the MAP_SHARED protections all together?

They survive my simple testing, but esp. the msync cleanup might need some
more attention.

I post them now instead of after a little more testing because I'll not 
have much time the coming few days to do so, and hoarding them does 
nobody any good.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
