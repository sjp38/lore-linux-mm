Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5BEA96B003A
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:43:16 -0400 (EDT)
Subject: [PATCH 05/16] fuse: Connection bit for enabling writeback
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:42:59 +0400
Message-ID: <20130629174253.20175.39262.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

From: Pavel Emelyanov <xemul@openvz.org>

Off (0) by default. Will be used in the next patches and will be turned
on at the very end.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 fs/fuse/fuse_i.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index fde7249..a0062a0 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -476,6 +476,9 @@ struct fuse_conn {
 	/** Set if bdi is valid */
 	unsigned bdi_initialized:1;
 
+	/** write-back cache policy (default is write-through) */
+	unsigned writeback_cache:1;
+
 	/*
 	 * The following bitfields are only for optimization purposes
 	 * and hence races in setting them will not cause malfunction

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
