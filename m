Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8701B6B0266
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 18:45:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so58385147pga.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 15:45:57 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n11si37788461plg.331.2016.11.30.15.45.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 15:45:56 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 4/6] dax: update MAINTAINERS entries for FS DAX
Date: Wed, 30 Nov 2016 16:45:31 -0700
Message-Id: <1480549533-29038-5-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Add the new include/trace/events/fs_dax.h tracepoint header, the existing
include/linux/dax.h header, update Matthew's email address and add myself
as a maintainer for filesystem DAX.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 MAINTAINERS | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2a58eea..b93ea2a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3855,10 +3855,13 @@ S:	Maintained
 F:	drivers/i2c/busses/i2c-diolan-u2c.c
 
 DIRECT ACCESS (DAX)
-M:	Matthew Wilcox <willy@linux.intel.com>
+M:	Matthew Wilcox <mawilcox@microsoft.com>
+M:	Ross Zwisler <ross.zwisler@linux.intel.com>
 L:	linux-fsdevel@vger.kernel.org
 S:	Supported
 F:	fs/dax.c
+F:	include/linux/dax.h
+F:	include/trace/events/fs_dax.h
 
 DIRECTORY NOTIFICATION (DNOTIFY)
 M:	Eric Paris <eparis@parisplace.org>
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
