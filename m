Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 078256B0272
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:06 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id c6-v6so7715327pll.4
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k123-v6si9280145pgc.203.2018.06.16.19.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:04 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 01/74] Update email address
Date: Sat, 16 Jun 2018 18:59:39 -0700
Message-Id: <20180617020052.4759-2-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Redirect some older email addresses that are in the git logs.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 .mailmap               | 7 +++++++
 MAINTAINERS            | 6 +++---
 include/linux/xarray.h | 2 +-
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/.mailmap b/.mailmap
index 29ddeb1bf015..a80dca923d32 100644
--- a/.mailmap
+++ b/.mailmap
@@ -114,6 +114,13 @@ Mark Brown <broonie@sirena.org.uk>
 Mark Yao <markyao0591@gmail.com> <mark.yao@rock-chips.com>
 Martin Kepplinger <martink@posteo.de> <martin.kepplinger@theobroma-systems.com>
 Martin Kepplinger <martink@posteo.de> <martin.kepplinger@ginzinger.com>
+Matthew Wilcox <willy@infradead.org> <matthew.r.wilcox@intel.com>
+Matthew Wilcox <willy@infradead.org> <matthew@wil.cx>
+Matthew Wilcox <willy@infradead.org> <mawilcox@linuxonhyperv.com>
+Matthew Wilcox <willy@infradead.org> <mawilcox@microsoft.com>
+Matthew Wilcox <willy@infradead.org> <willy@debian.org>
+Matthew Wilcox <willy@infradead.org> <willy@linux.intel.com>
+Matthew Wilcox <willy@infradead.org> <willy@parisc-linux.org>
 Matthieu CASTET <castet.matthieu@free.fr>
 Mauro Carvalho Chehab <mchehab@kernel.org> <mchehab@brturbo.com.br>
 Mauro Carvalho Chehab <mchehab@kernel.org> <maurochehab@gmail.com>
diff --git a/MAINTAINERS b/MAINTAINERS
index f15bc83753f5..6dc2c9cb2d7b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -529,7 +529,7 @@ F:	Documentation/hwmon/adt7475
 F:	drivers/hwmon/adt7475.c
 
 ADVANSYS SCSI DRIVER
-M:	Matthew Wilcox <matthew@wil.cx>
+M:	Matthew Wilcox <willy@infradead.org>
 M:	Hannes Reinecke <hare@suse.com>
 L:	linux-scsi@vger.kernel.org
 S:	Maintained
@@ -4268,7 +4268,7 @@ S:	Maintained
 F:	drivers/i2c/busses/i2c-diolan-u2c.c
 
 FILESYSTEM DIRECT ACCESS (DAX)
-M:	Matthew Wilcox <mawilcox@microsoft.com>
+M:	Matthew Wilcox <willy@infradead.org>
 M:	Ross Zwisler <ross.zwisler@linux.intel.com>
 L:	linux-fsdevel@vger.kernel.org
 S:	Supported
@@ -8452,7 +8452,7 @@ F:	drivers/message/fusion/
 F:	drivers/scsi/mpt3sas/
 
 LSILOGIC/SYMBIOS/NCR 53C8XX and 53C1010 PCI-SCSI drivers
-M:	Matthew Wilcox <matthew@wil.cx>
+M:	Matthew Wilcox <willy@infradead.org>
 L:	linux-scsi@vger.kernel.org
 S:	Maintained
 F:	drivers/scsi/sym53c8xx_2/
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 2dfc8006fe64..9e4c86853fa4 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -4,7 +4,7 @@
 /*
  * eXtensible Arrays
  * Copyright (c) 2017 Microsoft Corporation
- * Author: Matthew Wilcox <mawilcox@microsoft.com>
+ * Author: Matthew Wilcox <willy@infradead.org>
  */
 
 #include <linux/spinlock.h>
-- 
2.17.1
