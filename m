Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E13546B033C
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 13:49:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o68so15666060pfj.20
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 10:49:37 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o9si5972851pgf.246.2017.04.24.10.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 10:49:37 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 1/2] xfs: fix incorrect argument count check
Date: Mon, 24 Apr 2017 11:49:31 -0600
Message-Id: <20170424174932.15613-1-ross.zwisler@linux.intel.com>
In-Reply-To: <20170421034437.4359-1-ross.zwisler@linux.intel.com>
References: <20170421034437.4359-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fstests@vger.kernel.org, Xiong Zhou <xzhou@redhat.com>, jmoyer@redhat.com, eguan@redhat.com
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>

t_mmap_dio.c actually requires 4 arguments, not 3 as the current check
enforces:

usage: t_mmap_dio <src file> <dest file> <size> <msg>
open src(No such file or directory) len 0 (null)

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Fixes: 456581661b4d ("xfs: test per-inode DAX flag by IO")
---
 src/t_mmap_dio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/t_mmap_dio.c b/src/t_mmap_dio.c
index 69b9ca8..6c8ca1a 100644
--- a/src/t_mmap_dio.c
+++ b/src/t_mmap_dio.c
@@ -39,7 +39,7 @@ int main(int argc, char **argv)
 	char *dfile;
 	unsigned long len, opt;
 
-	if (argc < 4)
+	if (argc < 5)
 		usage(basename(argv[0]));
 
 	while ((opt = getopt(argc, argv, "b")) != -1)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
