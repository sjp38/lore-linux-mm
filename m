From: Corentin Labbe <clabbe@baylibre.com>
Subject: [PATCH] mm: shmem: remove unused info variable
Date: Wed, 15 Nov 2017 19:27:09 +0000
Message-ID: <1510774029-30652-1-git-send-email-clabbe@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe@baylibre.com>
List-Id: linux-mm.kvack.org

This patch fix the following build warning by simply removing the unused
info variable.
mm/shmem.c:3205:27: warning: variable 'info' set but not used [-Wunused-but-set-variable]

Signed-off-by: Corentin Labbe <clabbe@baylibre.com>
---
 mm/shmem.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 544c105d706a..7fbe67be86fa 100644
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
