Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 34E656B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 18:49:48 -0400 (EDT)
Date: Tue, 16 Jul 2013 15:49:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/11] ipc: drop ipcctl_pre_down
Message-Id: <20130716154945.91aebe21a18ef3c4580c7a91@linux-foundation.org>
In-Reply-To: <1371604716-3439-4-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
	<1371604716-3439-4-git-send-email-davidlohr.bueso@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Jun 2013 18:18:28 -0700 Davidlohr Bueso <davidlohr.bueso@hp.com> wrote:

> Now that sem, msgque and shm, through *_down(), all use the lockless
> variant of ipcctl_pre_down(), go ahead and delete it.

Fixlets:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: ipc-drop-ipcctl_pre_down-fix

fix function name in kerneldoc, cleanups

Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Manfred Spraul <manfred@colorfullife.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Sedat Dilek <sedat.dilek@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 ipc/util.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN ipc/util.c~ipc-drop-ipcctl_pre_down-fix ipc/util.c
--- a/ipc/util.c~ipc-drop-ipcctl_pre_down-fix
+++ a/ipc/util.c
@@ -733,7 +733,7 @@ int ipc_update_perm(struct ipc64_perm *i
 }
 
 /**
- * ipcctl_pre_down - retrieve an ipc and check permissions for some IPC_XXX cmd
+ * ipcctl_pre_down_nolock - retrieve an ipc and check permissions for some IPC_XXX cmd
  * @ns:  the ipc namespace
  * @ids:  the table of ids where to look for the ipc
  * @id:   the id of the ipc to retrieve
@@ -751,8 +751,8 @@ int ipc_update_perm(struct ipc64_perm *i
  * Call holding the both the rw_mutex and the rcu read lock.
  */
 struct kern_ipc_perm *ipcctl_pre_down_nolock(struct ipc_namespace *ns,
-					     struct ipc_ids *ids, int id, int cmd,
-					     struct ipc64_perm *perm, int extra_perm)
+					struct ipc_ids *ids, int id, int cmd,
+					struct ipc64_perm *perm, int extra_perm)
 {
 	kuid_t euid;
 	int err = -EPERM;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
