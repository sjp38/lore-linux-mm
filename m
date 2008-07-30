Subject: [PATCH] add prototype for down_try() to semaphore.h
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 30 Jul 2008 12:11:44 -0400
Message-Id: <1217434305.7676.8.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, rusty@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

I have needed this patch against the 29jul and 30jul mmotm to build.


Against:  mmotm 080730-0356

Fix to patch linux-next.patch
Required to build.


Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/semaphore.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.26/include/linux/semaphore.h
===================================================================
--- linux-2.6.26.orig/include/linux/semaphore.h	2008-07-29 13:00:43.000000000 -0400
+++ linux-2.6.26/include/linux/semaphore.h	2008-07-29 13:17:26.000000000 -0400
@@ -42,7 +42,7 @@ static inline void sema_init(struct sema
 extern void down(struct semaphore *sem);
 extern int __must_check down_interruptible(struct semaphore *sem);
 extern int __must_check down_killable(struct semaphore *sem);
-extern int __must_check down_trylock(struct semaphore *sem);
+extern int __must_check down_try(struct semaphore *sem);
 extern int __must_check down_timeout(struct semaphore *sem, long jiffies);
 extern void up(struct semaphore *sem);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
