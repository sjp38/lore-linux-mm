Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B53DAC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BF0721473
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BF0721473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A05A56B0006; Mon, 29 Apr 2019 00:54:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B48B6B0007; Mon, 29 Apr 2019 00:54:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CF936B0008; Mon, 29 Apr 2019 00:54:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 569686B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f7so6605388pgi.20
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oR/A81zHUI++6YmU7SrQg0mkfo3ZZeuMi+szp2IyjJc=;
        b=h8rSCagdxNcVWC5MNxmjV/crboltQgWK/1N7ANaG9JA5+TDbTg17ZBa6IK1vrG78GO
         z7KNmp2uO3bnwRXJ6S6GtD3zmnv5sBbMdW6eABPEa/fizRux0RkybHgfRWpyYYB36+ZK
         Mn2w5pnF2HeI/ad9J4xGdYknNrNFC7171tTznNXwp2L2y9sy72LFnZluYDpmucslR9aS
         rW7z/BBbdFPuculwRT/IFaPFQhWJAYH3JkRylEb889jH65+IHJpBEFs1KH+DJd6VdhlW
         evNjUAbw6wSYvyLG0ocwks1c4NevRfYPsmPIRmS5abgSL9Mxr8WiKCevKmHriytUT1PM
         3NmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVRWtiigYh/di00mYfnGo9Vmy+ik9YLTpvKrl8r0JYGvwllTV9B
	a69IHoiccMsc8BatKJCPDKIdwyScTSjXiUX2PA0YYVewktt01i8FLvwoZl1FfnBl1ryClRjXxOO
	sBKY5xUYm85pA3PvBEuPIJV2Sm6tTkWE5nkg+jIMQ8NsBxxA/Gi2FU/Y/C1axPJlYDw==
X-Received: by 2002:a17:902:a515:: with SMTP id s21mr9006744plq.131.1556513646041;
        Sun, 28 Apr 2019 21:54:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqRbDvyrUqBddtpsd86XXdj6P87c7Tk+ytPs4Q6RTcv2phppvt3uQu9UlcKEBiG+PMFSVP
X-Received: by 2002:a17:902:a515:: with SMTP id s21mr9006705plq.131.1556513645335;
        Sun, 28 Apr 2019 21:54:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513645; cv=none;
        d=google.com; s=arc-20160816;
        b=kLjz2xcM/CUih5WtpcvQ3cXxyloB0nV1eovenJBlgXIZoRj5Un4p0dRGYd3ouoLd8X
         /8jWato1W6i4KeL1IHWTj8ovcaP5FIRQFWpLrCgrLUuSJa84Y7gQbtu3vSuRqdTsz9bX
         NkAnyKyvoS1oMFRPCv0pOixFVoh3EaQ5IfjOm/gRYCDed5ExJSyDaEcSgT83fdhZhFEr
         vHkByhwETR9bB5le7ETws8R3rABU1QckNAk0rcpFS7CQYtDQEvHhCJZ/zBK15LZlZAMD
         GtKkBdwgJikAM1LUA3rhdhkl7aTe4vkNKxDbl5yNyJ8BE+XizXmFnlhgI+NUoje5Uk0h
         zOTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=oR/A81zHUI++6YmU7SrQg0mkfo3ZZeuMi+szp2IyjJc=;
        b=tNjFFL03WYEfliXc7WHIgeyp+YmMgDUVUtKp3clYDmSmSY8Co/ZQh+BNilerHnDdVu
         1S1iAEGD6CQwuszeZP8Rv7Tw3wnGErWdmBd5t1/ITQLA3fBilng2oM6cNlZyzQRkePEW
         qjxOeK7gMgbgbDOknfGShVf7fhyO5ca+4eg5nMKUgM4vI4dDH3MNpco+Pd02oljrbaYP
         A2mXgvBoJtVgMU0aSVtnbclP0WcVu6eNurVTl/ykOb6vN6i8HPeCGk5biyqhumUI5oCN
         T4UmpbIkeuWTKHc67/3UaeXKPVRWMtbDxkItLNvX0tRvdtPk97yj6SigH8vom46nlhjS
         q0VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m184si14181099pfb.166.2019.04.28.21.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 21:54:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566271"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Apr 2019 21:54:04 -0700
From: ira.weiny@intel.com
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH 01/10] fs/locks: Add trace_leases_conflict
Date: Sun, 28 Apr 2019 21:53:50 -0700
Message-Id: <20190429045359.8923-2-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190429045359.8923-1-ira.weiny@intel.com>
References: <20190429045359.8923-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/locks.c                      | 20 ++++++++++++++-----
 include/trace/events/filelock.h | 35 +++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+), 5 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index eaa1cfaf73b0..4b66ed91fb53 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1528,11 +1528,21 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 
 static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 {
-	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT))
-		return false;
-	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
-		return false;
-	return locks_conflict(breaker, lease);
+	bool rc;
+
+	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT)) {
+		rc = false;
+		goto trace;
+	}
+	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE)) {
+		rc = false;
+		goto trace;
+	}
+
+	rc = locks_conflict(breaker, lease);
+trace:
+	trace_leases_conflict(rc, lease, breaker);
+	return rc;
 }
 
 static bool
diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
index fad7befa612d..4b735923f2ff 100644
--- a/include/trace/events/filelock.h
+++ b/include/trace/events/filelock.h
@@ -203,6 +203,41 @@ TRACE_EVENT(generic_add_lease,
 		show_fl_type(__entry->fl_type))
 );
 
+TRACE_EVENT(leases_conflict,
+	TP_PROTO(bool conflict, struct file_lock *lease, struct file_lock *breaker),
+
+	TP_ARGS(conflict, lease, breaker),
+
+	TP_STRUCT__entry(
+		__field(void *, lease)
+		__field(void *, breaker)
+		__field(unsigned int, l_fl_flags)
+		__field(unsigned int, b_fl_flags)
+		__field(unsigned char, l_fl_type)
+		__field(unsigned char, b_fl_type)
+		__field(bool, conflict)
+	),
+
+	TP_fast_assign(
+		__entry->lease = lease;
+		__entry->l_fl_flags = lease->fl_flags;
+		__entry->l_fl_type = lease->fl_type;
+		__entry->breaker = breaker;
+		__entry->b_fl_flags = breaker->fl_flags;
+		__entry->b_fl_type = breaker->fl_type;
+		__entry->conflict = conflict;
+	),
+
+	TP_printk("conflict %d: lease=0x%p fl_flags=%s fl_type=%s; breaker=0x%p fl_flags=%s fl_type=%s",
+		__entry->conflict,
+		__entry->lease,
+		show_fl_flags(__entry->l_fl_flags),
+		show_fl_type(__entry->l_fl_type),
+		__entry->breaker,
+		show_fl_flags(__entry->b_fl_flags),
+		show_fl_type(__entry->b_fl_type))
+);
+
 #endif /* _TRACE_FILELOCK_H */
 
 /* This part must be outside protection */
-- 
2.20.1

