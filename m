Subject: [PATCH] fix2 to putback_lru_page()/unevictable page handling
	rework v3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080624114006.D81C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080621185408.E832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080624114006.D81C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Date: Tue, 24 Jun 2008 13:29:32 -0400
Message-Id: <1214328572.6563.31.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

PATCH revert shmem_lock() prototypes to return int

Against: 26-rc5-mm3 with Kosaki Motohiro's splitlru unevictable lru
fixes.

Fix to i>>?putback_lru_page()/unevictable page handling rework v3 patch.

The subject patch reverted a prior change to shmem_lock() to return a
struct address_space pointer back to returning an int.  This patch
updates the prototypes in mm.h to match.  

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mm.h |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

Index: linux-2.6.26-rc5-mm3/include/linux/mm.h
===================================================================
--- linux-2.6.26-rc5-mm3.orig/include/linux/mm.h	2008-06-24 12:54:41.000000000 -0400
+++ linux-2.6.26-rc5-mm3/include/linux/mm.h	2008-06-24 13:25:29.000000000 -0400
@@ -706,13 +706,12 @@ static inline int page_mapped(struct pag
 extern void show_free_areas(void);
 
 #ifdef CONFIG_SHMEM
-extern struct address_space *shmem_lock(struct file *file, int lock,
-					struct user_struct *user);
+extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 #else
-static inline struct address_space *shmem_lock(struct file *file, int lock,
+static inline int shmem_lock(struct file *file, int lock,
 					struct user_struct *user)
 {
-	return NULL;
+	return 0;
 }
 #endif
 struct file *shmem_file_setup(char *name, loff_t size, unsigned long flags);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
