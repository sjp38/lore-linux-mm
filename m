Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC0B6B000A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:10:56 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 14-v6so3177673pfk.22
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:10:56 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 97-v6si22987597plm.290.2018.10.09.17.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:10:55 -0700 (PDT)
Subject: [PATCH 01/25] xfs: add a per-xfs trace_printk macro
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:10:45 -0700
Message-ID: <153913024554.32295.8692450593333636905.stgit@magnolia>
In-Reply-To: <153913023835.32295.13962696655740190941.stgit@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Add a "xfs_tprintk" macro so that developers can use trace_printk to
print out arbitrary debugging information with the XFS device name
attached to the trace output.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_error.h |    5 +++++
 1 file changed, 5 insertions(+)


diff --git a/fs/xfs/xfs_error.h b/fs/xfs/xfs_error.h
index 246d3e989c6c..c3d9546b138c 100644
--- a/fs/xfs/xfs_error.h
+++ b/fs/xfs/xfs_error.h
@@ -99,4 +99,9 @@ extern int xfs_errortag_clearall(struct xfs_mount *mp);
 #define		XFS_PTAG_SHUTDOWN_LOGERROR	0x00000040
 #define		XFS_PTAG_FSBLOCK_ZERO		0x00000080
 
+/* trace printk version of xfs_err and friends */
+#define xfs_tprintk(mp, fmt, args...) \
+	trace_printk("dev %d:%d " fmt, MAJOR((mp)->m_super->s_dev), \
+			MINOR((mp)->m_super->s_dev), ##args)
+
 #endif	/* __XFS_ERROR_H__ */
