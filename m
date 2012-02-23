Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 0998F6B007E
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:51:07 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/3] NOMMU: Don't need to clear vm_mm when deleting a VMA
Date: Thu, 23 Feb 2012 13:51:00 +0000
Message-ID: <20120223135100.24278.472.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120223135035.24278.96099.stgit@warthog.procyon.org.uk>
References: <20120223135035.24278.96099.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, uclinux-dev@uclinux.org, gerg@uclinux.org, lethal@linux-sh.org, David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, stable@vger.kernel.org

Don't clear vm_mm in a deleted VMA as it's unnecessary and might conceivably
break the filesystem or driver VMA close routine.

Reported-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
cc: stable@vger.kernel.org
---

 mm/nommu.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)


diff --git a/mm/nommu.c b/mm/nommu.c
index d02ee35..3d39992 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -770,8 +770,6 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 
 	if (vma->vm_next)
 		vma->vm_next->vm_prev = vma->vm_prev;
-
-	vma->vm_mm = NULL;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
