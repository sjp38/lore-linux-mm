Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7556B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 02:41:47 -0500 (EST)
Date: Wed, 28 Jan 2009 16:26:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH] migration: migrate_vmas should check "vma"
Message-Id: <20090128162619.2205befd.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

migrate_vmas() should check "vma" not "vma->vm_next" for for-loop condition.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/migrate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 2bb4e1d..a9eff3f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1129,7 +1129,7 @@ int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
  	struct vm_area_struct *vma;
  	int err = 0;
 
- 	for(vma = mm->mmap; vma->vm_next && !err; vma = vma->vm_next) {
+	for (vma = mm->mmap; vma && !err; vma = vma->vm_next) {
  		if (vma->vm_ops && vma->vm_ops->migrate) {
  			err = vma->vm_ops->migrate(vma, to, from, flags);
  			if (err)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
