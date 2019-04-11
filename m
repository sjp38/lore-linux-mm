Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D56DC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 488E52084D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:22:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dzUaWrS7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 488E52084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6A946B0006; Thu, 11 Apr 2019 07:22:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D186A6B0007; Thu, 11 Apr 2019 07:22:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDFEF6B000E; Thu, 11 Apr 2019 07:22:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 707D06B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:22:02 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id a206so3509003wmh.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:22:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=oB8WVm0U30VgaAgSIfIcoQ43KEp9ofOnz5AKOBoqL9Q=;
        b=foaqQPDmV35WEo9rX0BzCyL0pBvSR9josbfe0vuKFrHCbPvLFcMlBSKmGd3rREo4E4
         gzO0sqx/M15MUfVbVXWyLFrSOFkNlzTf+3AGQ/WfEgg0iK00PAav9f2L/KDmU8iSJmFo
         rhDrjKi/hNgxA6h8VSy2YJE3fPQyh6xNaOHhiaaSpphPkR2CJvhdiSvYTPxGd2oAPMKe
         GlWM2le52SADl293nw15otof+bXQun9M1DcKk6+GIS2bVatoCdPSHBdw4BhQonHlUaZF
         gGcbH8e7Ia8RycB1IUnAiK2RABOUbWJ3bQeYt1R43j5RzRrtaOFDl56sMgQ+Cx4uga2m
         5SXQ==
X-Gm-Message-State: APjAAAXwJNPQsY/MqBDPhmtrInCbF+5ucO0DVZXC6Dw0iuTkOLl8d1CB
	AeRDXakL3r58kl4kksOhCzjTr1ElVxf26OwzasPMyvfySUg/rxjfE10EWaQYiswJRTkZ4JGLICn
	mUP/PeBr4tosBJr2u6B6AX7jF14uJonVKXSjDYQfF8FWxbmk1BECHn96+AiTQV9O6sA==
X-Received: by 2002:a7b:cc91:: with SMTP id p17mr6309682wma.38.1554981721933;
        Thu, 11 Apr 2019 04:22:01 -0700 (PDT)
X-Received: by 2002:a7b:cc91:: with SMTP id p17mr6309602wma.38.1554981720828;
        Thu, 11 Apr 2019 04:22:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554981720; cv=none;
        d=google.com; s=arc-20160816;
        b=Im8ThhV5KlMFGFgeMi0H43uNMzXxbsI0mTYMCbPChFqkHKoqQZ5mE1NO1vUkfd/II5
         TmDoRRBbtnC3geJPPP3JbwgUeFw58a9UZZhM0Tx6BjC1Bv+p6PQpV6uL2F0m+ezUYDUL
         pILRB+BnMFB1KLdoC5xiCHw+h1c873G3mb9ZQ2utJzFczvxUOt15jlX6Lne1/jXUepm8
         5ecB9RMzHU02seu+mnluLO6DNjXexx7fXqpCrZRtaxeeB/TDNSxzX56CJvtQBWigkwzo
         7tE5sFKyz/Eh1KnEBe1j8cEZ5AnjBJ8Zc3i2AxgK1oAuTY87VcBJ9Yjz2JCwG3nNCQ9o
         XvWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=oB8WVm0U30VgaAgSIfIcoQ43KEp9ofOnz5AKOBoqL9Q=;
        b=093Rp+fYJ+/XzXtUITL7rcOWHJBakcNi6KInhPXXAZtRapbhux42EABLSSfHU+Rr47
         4XfopwGxrWwXys11plQJFWZCx2EK6yKYJEc1RQhHpIpG3SDGkyshU6EygWZZoVio/ixh
         dHS2ubxqd3MFdOa4RRZrG8j+mBUh6axTeJq1EfJi/7+JPDIHYahyoZ33D8b3tfF2OiRp
         GzXxxf/zXns+djndJe1+z3RbkFphgjSfi0f5HF8TfmAN/wpNd56Qn1r/nJh3AnpwrrId
         TV7oUQVDxPm8I73GjCxRpR0G1n95Y92GmaYMJhgUZQaNllrtrnkkcelZVW45NKMJcCTQ
         eEaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dzUaWrS7;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor28871949wro.43.2019.04.11.04.22.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 04:22:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dzUaWrS7;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=oB8WVm0U30VgaAgSIfIcoQ43KEp9ofOnz5AKOBoqL9Q=;
        b=dzUaWrS7cPOeBeEewgm4b4/7FkQjDR5/n28/v+0u0PZFtyYdg+MazGNykSuiKEVJQI
         uqjICHM8mso6HJ4t+kKsH7AHztuFbESqqTQtpJkWoIrZ9IGlE2Ehs59zPAo683F06F4/
         fuFu4Wd1ViQLaERA6aR+hCLq/SouttZt08mi8NAwBLD5JBRVoIXbSEOyLtDzF/UIN/mk
         bFUzq7ID1aiRzg9x/KiWpf6W5LY9KEou+IUeGoE0/EBRWqwX1jR4Ke6AGXRUiw6oQFLw
         NbQsVeulf31vsU3v+8qGy11s3+7qUn6M0ruTu58eOA9pYzOYcuZIXZcR6a6j3DPF9W1W
         UXCA==
X-Google-Smtp-Source: APXvYqztyzKtf+Ci2S9cRUMlUpdQD2ffSUboqKvZFrRpQOdyWaY2njO98vCPHKXsMAO/FtYvRCrW8Q==
X-Received: by 2002:a5d:54c4:: with SMTP id x4mr30183182wrv.296.1554981720409;
        Thu, 11 Apr 2019 04:22:00 -0700 (PDT)
Received: from localhost.localdomain (bzq-166-168-31-246.red.bezeqint.net. [31.168.166.246])
        by smtp.gmail.com with ESMTPSA id s2sm5711931wmc.7.2019.04.11.04.21.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 04:21:59 -0700 (PDT)
From: Amir Goldstein <amir73il@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2] fs/sync.c: sync_file_range(2) may use WB_SYNC_ALL writeback
Date: Thu, 11 Apr 2019 14:21:52 +0300
Message-Id: <20190411112152.32151-1-amir73il@gmail.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 23d0127096cb ("fs/sync.c: make sync_file_range(2) use WB_SYNC_NONE
writeback") claims that sync_file_range(2) syscall was "created for
userspace to be able to issue background writeout and so waiting for
in-flight IO is undesirable there" and changes the writeback (back) to
WB_SYNC_NONE.

This claim is only partially true. It is true for users that use the flag
SYNC_FILE_RANGE_WRITE by itself, as does PostgreSQL, the user that was
the reason for changing to WB_SYNC_NONE writeback.

However, that claim is not true for users that use that flag combination
SYNC_FILE_RANGE_{WAIT_BEFORE|WRITE|_WAIT_AFTER}.
Those users explicitly requested to wait for in-flight IO as well as to
writeback of dirty pages.

Re-brand that flag combination as SYNC_FILE_RANGE_WRITE_AND_WAIT
and use the helper filemap_write_and_wait_range(), that uses WB_SYNC_ALL
writeback, to perform the full range sync request.

Fixes: 23d0127096cb ("fs/sync.c: make sync_file_range(2) use WB_SYNC_NONE")
Acked-by: Jan Kara <jack@suse.com>
Signed-off-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/sync.c               | 25 ++++++++++++++++++-------
 include/uapi/linux/fs.h |  3 +++
 2 files changed, 21 insertions(+), 7 deletions(-)

Andrew,

Since you were the one to merge Jan's patch that this Fixes,
I figured it would be best to send the fix through your tree.

You may find the discussion on V1 here:
https://lore.kernel.org/lkml/20190409114922.30095-1-amir73il@gmail.com/

Thanks,
Amir.

Changes since v1:
- Remove non-guaranties of the API from commit message
- Added ACK by Jan

diff --git a/fs/sync.c b/fs/sync.c
index b54e0541ad89..5cf6fdbae4de 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -18,8 +18,8 @@
 #include <linux/backing-dev.h>
 #include "internal.h"
 
-#define VALID_FLAGS (SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE| \
-			SYNC_FILE_RANGE_WAIT_AFTER)
+#define VALID_FLAGS (SYNC_FILE_RANGE_WRITE | SYNC_FILE_RANGE_WRITE_AND_WAIT | \
+		     SYNC_FILE_RANGE_WAIT_BEFORE | SYNC_FILE_RANGE_WAIT_AFTER)
 
 /*
  * Do the filesystem syncing work. For simple filesystems
@@ -235,9 +235,9 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
 }
 
 /*
- * sys_sync_file_range() permits finely controlled syncing over a segment of
+ * ksys_sync_file_range() permits finely controlled syncing over a segment of
  * a file in the range offset .. (offset+nbytes-1) inclusive.  If nbytes is
- * zero then sys_sync_file_range() will operate from offset out to EOF.
+ * zero then ksys_sync_file_range() will operate from offset out to EOF.
  *
  * The flag bits are:
  *
@@ -254,7 +254,7 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
  * Useful combinations of the flag bits are:
  *
  * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE: ensures that all pages
- * in the range which were dirty on entry to sys_sync_file_range() are placed
+ * in the range which were dirty on entry to ksys_sync_file_range() are placed
  * under writeout.  This is a start-write-for-data-integrity operation.
  *
  * SYNC_FILE_RANGE_WRITE: start writeout of all dirty pages in the range which
@@ -266,10 +266,13 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
  * earlier SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE operation to wait
  * for that operation to complete and to return the result.
  *
- * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER:
+ * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER
+ * (a.k.a. SYNC_FILE_RANGE_WRITE_AND_WAIT):
  * a traditional sync() operation.  This is a write-for-data-integrity operation
  * which will ensure that all pages in the range which were dirty on entry to
- * sys_sync_file_range() are committed to disk.
+ * ksys_sync_file_range() are written to disk.  It should be noted that disk
+ * caches are not flushed by this call, so there are no guarantees here that the
+ * data will be available on disk after a crash.
  *
  *
  * SYNC_FILE_RANGE_WAIT_BEFORE and SYNC_FILE_RANGE_WAIT_AFTER will detect any
@@ -338,6 +341,14 @@ int ksys_sync_file_range(int fd, loff_t offset, loff_t nbytes,
 
 	mapping = f.file->f_mapping;
 	ret = 0;
+	if ((flags & SYNC_FILE_RANGE_WRITE_AND_WAIT) ==
+		     SYNC_FILE_RANGE_WRITE_AND_WAIT) {
+		/* Unlike SYNC_FILE_RANGE_WRITE alone uses WB_SYNC_ALL */
+		ret = filemap_write_and_wait_range(mapping, offset, endbyte);
+		if (ret < 0)
+			goto out_put;
+	}
+
 	if (flags & SYNC_FILE_RANGE_WAIT_BEFORE) {
 		ret = file_fdatawait_range(f.file, offset, endbyte);
 		if (ret < 0)
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 121e82ce296b..59c71fa8c553 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -320,6 +320,9 @@ struct fscrypt_key {
 #define SYNC_FILE_RANGE_WAIT_BEFORE	1
 #define SYNC_FILE_RANGE_WRITE		2
 #define SYNC_FILE_RANGE_WAIT_AFTER	4
+#define SYNC_FILE_RANGE_WRITE_AND_WAIT	(SYNC_FILE_RANGE_WRITE | \
+					 SYNC_FILE_RANGE_WAIT_BEFORE | \
+					 SYNC_FILE_RANGE_WAIT_AFTER)
 
 /*
  * Flags for preadv2/pwritev2:
-- 
2.17.1

