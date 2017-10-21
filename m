From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] mm: shmem: Fix build warning
Date: Sat, 21 Oct 2017 18:50:32 +0200
Message-ID: <20171021165032.20542-1-clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe.montjoie@gmail.com>
List-Id: linux-mm.kvack.org

This patch fix the following build warning by simply removing the unused
info variable.
linux-next/mm/shmem.c:3205:27: warning: variable 'info' set but not used [-Wunused-but-set-variable]

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 mm/shmem.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 9a981f063d5d..ffa5897b8a0c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3202,7 +3202,6 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 	int len;
 	struct inode *inode;
 	struct page *page;
-	struct shmem_inode_info *info;
 
 	len = strlen(symname) + 1;
 	if (len > PAGE_SIZE)
@@ -3222,7 +3221,6 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		error = 0;
 	}
 
-	info = SHMEM_I(inode);
 	inode->i_size = len-1;
 	if (len <= SHORT_SYMLINK_LEN) {
 		inode->i_link = kmemdup(symname, len, GFP_KERNEL);
-- 
2.13.6
