Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C802DC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:29:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7012C217D7
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:29:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rotvELed"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7012C217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18DCC6B026D; Fri, 19 Apr 2019 03:29:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13E4A6B026E; Fri, 19 Apr 2019 03:29:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02D166B026F; Fri, 19 Apr 2019 03:29:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB5956B026D
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 03:29:47 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id f12so3829484wmj.0
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 00:29:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=JUrL+t/sGkk+Nd+0JlZtFUe7lRgqB2NCcYxNia/KE+Q=;
        b=nhOkRvR7s8vCkE0SLpnrUaYOSbbzbJ+W2pjtEJlypwVDIDk+k2+N8JJ8l0uFObvqVJ
         BzXyggni3I2y3VPm91m4tTLF9Ze25VQ/biWFBavrvpsotEQFEkSN6ts6SBDG3HlQ/tu1
         2+/o3HkPsC4N0vOmf1TpHWkChllSzVcQ66jlT9t3PFqBpGAKSvij3SPpPAXv4MwYQOSH
         KPRH00akNHVKL8IQ40L/uGdbC3x25knxe0PNtIwaF4qGEdATtGI98hPry/nHfQncIw1u
         rRCEiotIdlH3+CWWm1vUyBL5FQcNMdW+UBynjVz0WtymhVGS1E9CC5s5rA19tKacudY3
         4l2A==
X-Gm-Message-State: APjAAAUPR3OTF5qRH94M+87QbTnDHdkO9yQV+DEVEVx1d5X8wU8k9n0y
	fwKp8TC+EW9T7kyre6xV4IR0Aio7gZpmjxkzpe2Zu+OsXsFUNFc2MQidAQ0dfb1FTWY86ioNYo6
	PGTqlVPYfb0e5pbHtlTUsmGZdOqlP70iG9pIN31Ze9jZcevuyYKtYgt1lZ+86vByvvQ==
X-Received: by 2002:adf:e547:: with SMTP id z7mr1718043wrm.295.1555658987190;
        Fri, 19 Apr 2019 00:29:47 -0700 (PDT)
X-Received: by 2002:adf:e547:: with SMTP id z7mr1717988wrm.295.1555658986288;
        Fri, 19 Apr 2019 00:29:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555658986; cv=none;
        d=google.com; s=arc-20160816;
        b=0jijGJUSw4RTH/h4/I7CrATcTrY8vGcEL0untlroRNr1LTQfJzswJ1JB/BtFf1n6UM
         RM27497zK058xSaTSg48NtQ+8c01DzRo3K2P2kDanThJZh8ipB/rgya5nL3LQK3Hm6ji
         /6YFaNFOpr5CnPEPxLCBjucVY5lt53bma6HaW2p4RRVSf8YWjdZD6U0sss6bJN14G4gJ
         4oNsklaf+1VVXjOXzbKnvZK2JmT36XUo61R5Js972pLrIWwlZH1rvyO6G3YXI1Smf3pc
         dtxDXiLupV7t58CV3iNe00y1MEG2dZXrYz8LmY609XyisaB/U+PbUN9xKELG4WrGxtLW
         un6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=JUrL+t/sGkk+Nd+0JlZtFUe7lRgqB2NCcYxNia/KE+Q=;
        b=0nIactzNsrKFp89Jf+Ur02yr+tsLuzwEoAk8dPR0k9aEkBPJDkgfHA4IsN4CGd5DW8
         +ILV1B8Tqux4U9qD+EQn6owpdKkoQV1wgnKz4MYTHhWQy7hADHC5cH+mgU+Bn+LpeEe6
         qtnedWF/2Y8HtXBecjXunXHQOXMkv89ELDxMCeHSAngi0lpB66cpdl5Pr+u33Tg6Qov1
         euSI9hf6uK5QfE4N4Ezx24B2/2iUG/1HsABOGnt5bW3suqL5AybtwCis99We1gA1JU78
         Rfxr5pItHb+HkzdXd2DDXm4YSvYcEAHhVoW0JDQ9Sx/dv9T+IUqyjLiOA4wTrSO2iM0s
         RvWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rotvELed;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o3sor2409997wmo.17.2019.04.19.00.29.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Apr 2019 00:29:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rotvELed;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=JUrL+t/sGkk+Nd+0JlZtFUe7lRgqB2NCcYxNia/KE+Q=;
        b=rotvELedYkfsMEDZw4+zMLSEYZrkCQewj8XNhvPQou+5xQKTeUyv8KrZyggorJjGET
         r1bPrfPqlprXmHjt4LF97AXqE53KYsdrIivOj/iUxhAEJNoFXwb1FZyMnM6MKwYqjz+6
         +Jb/qqEqizgyeYOki11WGYIZ26MT+o1hZ9kxndi66xVXSd0O0luLLecSu6Y/Fzk1Pkwr
         bfvsIVJkm5WbktC8x5Rbd9azkPzVsjBl6UA94mBhq4ECHJrWqy/sIeqRL5FjOgf4P9Sx
         ne2S82CNtSBXvBagWsq6ifC3WE6CmnwFySpL6b/8RKkrJcxXHqwGuKjYprV7jr4nHqMa
         nuGA==
X-Google-Smtp-Source: APXvYqzOWHpn1wSg+lT9K1wFIQIDgkcFXYdMOItJU3yOIH6AH4oCYQEiO3Wcw3VfodNnpv1E78czBA==
X-Received: by 2002:a1c:9dc8:: with SMTP id g191mr1608551wme.132.1555658985835;
        Fri, 19 Apr 2019 00:29:45 -0700 (PDT)
Received: from localhost.localdomain ([5.102.238.208])
        by smtp.gmail.com with ESMTPSA id z18sm5481865wrr.90.2019.04.19.00.29.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 00:29:45 -0700 (PDT)
From: Amir Goldstein <amir73il@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v5] fs/sync.c: sync_file_range(2) may use WB_SYNC_ALL writeback
Date: Fri, 19 Apr 2019 10:29:38 +0300
Message-Id: <20190419072938.31320-1-amir73il@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190419000225.GF1454@dread.disaster.area>
References: <20190419000225.GF1454@dread.disaster.area>
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
and use WB_SYNC_ALL writeback to perform the full range sync request.

Link: http://lkml.kernel.org/r/20190409114922.30095-1-amir73il@gmail.com
Fixes: 23d0127096cb ("fs/sync.c: make sync_file_range(2) use WB_SYNC_NONE")
Signed-off-by: Amir Goldstein <amir73il@gmail.com>
Acked-by: Jan Kara <jack@suse.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---

Andrew,

One more version addressing another comment by Dave Chinner.

Thanks,
Amir.

Changes since v4:
- Don't use filemap_write_and_wait_range() helper (Dave)

Changes since v3:
- Remove unneeded change to VALID_FLAGS (Dave)
- Call file_fdatawait_range() before writeback (Dave)

Changes since v2:
- Return after filemap_write_and_wait_range()

Changes since v1:
- Remove non-guaranties of the API from commit message
- Added ACK by Jan

 fs/sync.c               | 21 +++++++++++++++------
 include/uapi/linux/fs.h |  3 +++
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/sync.c b/fs/sync.c
index b54e0541ad89..9e8cd90e890f 100644
--- a/fs/sync.c
+++ b/fs/sync.c
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
@@ -345,8 +348,14 @@ int ksys_sync_file_range(int fd, loff_t offset, loff_t nbytes,
 	}
 
 	if (flags & SYNC_FILE_RANGE_WRITE) {
+		int sync_mode = WB_SYNC_NONE;
+
+		if ((flags & SYNC_FILE_RANGE_WRITE_AND_WAIT) ==
+			     SYNC_FILE_RANGE_WRITE_AND_WAIT)
+			sync_mode = WB_SYNC_ALL;
+
 		ret = __filemap_fdatawrite_range(mapping, offset, endbyte,
-						 WB_SYNC_NONE);
+						 sync_mode);
 		if (ret < 0)
 			goto out_put;
 	}
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

