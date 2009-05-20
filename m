Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF8D6B009C
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:49:47 -0400 (EDT)
Date: Wed, 20 May 2009 11:50:05 -0700
From: "Larry H." <research@subreption.com>
Subject: [patch 3/5] Apply the PG_sensitive flag to audit subsystem
Message-ID: <20090520185005.GC10756@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, faith@redhat.com
List-ID: <linux-mm.kvack.org>

This patch deploys the use of the PG_sensitive page allocator flag
within the audit subsystem. It's not necessarily a high profile
target for use of this flag, but could be expected to contain
potentially sensitive information under some circumstances.

Signed-off-by: Larry H. <research@subreption.com>

---
 kernel/audit.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/kernel/audit.c
===================================================================
--- linux-2.6.orig/kernel/audit.c
+++ linux-2.6/kernel/audit.c
@@ -1061,6 +1061,9 @@ static struct audit_buffer * audit_buffe
 	}
 	spin_unlock_irqrestore(&audit_freelist_lock, flags);
 
+	if (!(gfp_mask & GFP_SENSITIVE))
+		gfp_mask |= GFP_SENSITIVE;
+
 	if (!ab) {
 		ab = kmalloc(sizeof(*ab), gfp_mask);
 		if (!ab)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
