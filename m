Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A6A016006B6
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 22:45:17 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o6L2jENg030818
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:14 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz37.hot.corp.google.com with ESMTP id o6L2jCsm013358
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:13 -0700
Received: by pxi12 with SMTP id 12so262711pxi.6
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:12 -0700 (PDT)
Date: Tue, 20 Jul 2010 19:45:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
In-Reply-To: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The kzalloc() in start_this_handle() is failable, so remove __GFP_NOFAIL
from its mask.

Cc: Andreas Dilger <adilger@sun.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/jbd2/transaction.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -102,8 +102,7 @@ static int start_this_handle(journal_t *journal, handle_t *handle)
 
 alloc_transaction:
 	if (!journal->j_running_transaction) {
-		new_transaction = kzalloc(sizeof(*new_transaction),
-						GFP_NOFS|__GFP_NOFAIL);
+		new_transaction = kzalloc(sizeof(*new_transaction), GFP_NOFS):
 		if (!new_transaction) {
 			ret = -ENOMEM;
 			goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
