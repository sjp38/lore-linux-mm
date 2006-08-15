Date: Tue, 15 Aug 2006 17:56:07 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Message-Id: <20060815225607.17433.32727.sendpatch@wildcat>
Subject: [PATCH 0/2] Latest shared page table patches
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>, Diego Calleja <diegocg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Here is the latest copy of the shared page table patches.  They're
slimmed down a lot and have better synchronization to guarantee no
race conditions.

They also do partial page sharing.  A vma can be any size and alignment
and have its page table shared as long as it's the only vma in the pte page.

Dave McCracken

------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
