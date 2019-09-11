Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E14CECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:10:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 545E0222BF
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:10:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 545E0222BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 088C66B000A; Wed, 11 Sep 2019 03:10:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 039C66B000C; Wed, 11 Sep 2019 03:10:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E91AA6B000D; Wed, 11 Sep 2019 03:10:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id C45316B000A
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:10:43 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 7130A181AC9C9
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:43 +0000 (UTC)
X-FDA: 75921767166.07.price93_7aaa33c3ddb12
X-HE-Tag: price93_7aaa33c3ddb12
X-Filterd-Recvd-Size: 7680
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:42 +0000 (UTC)
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EFE8D3D94D
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:41 +0000 (UTC)
Received: by mail-pl1-f197.google.com with SMTP id v4so11394560plp.23
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 00:10:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=RRZuHtIpu1kWmysN8fGt73f3ShagvK1FUD0BwRzbsQk=;
        b=eMdi8kFcIsq2qq2iK5M0r//ubP6hRaKZdHtf5tnjblEpnC+xAlUSn8dt3r8+QAjbDs
         DswP/Sih8pPq9XO+r8L9DuEy4mVbb+TPCoCcCEecrLTzY0Jm0YZL5if0hsoU8voo/ITv
         N/mg51OxDjjzHUH3ihxr2KAbaJSdcM3ZaW+nrpkB1CzSvPllyzJVu/TO2qwbP3fgL8/c
         8Z3WfPeyylY7GkR0gcDg1P0w3h1qjLqBfcTQPFUdwajkYwew1+WQ537OKGwPdFqmBpF3
         iusyhhUrEMRHgkg62Ik5i2Uh17+xJxeFdPQOPQjQskHS+rSRxD55yhiBEP/RrVYkzTbO
         b64w==
X-Gm-Message-State: APjAAAXZndpbtceavmbS2yBpuFrvQoeNiOdpVmr38HPhON62PDixYq7I
	qvRG3AkeTxx4/GrF0ipTQxbfqHcPr6ZwmXJ7Y7uIPStuqTq/BXzWDdd68LKluoQAZmm2yEXYIkM
	kPxHOszhwVAU=
X-Received: by 2002:a17:90a:8087:: with SMTP id c7mr3941901pjn.59.1568185840961;
        Wed, 11 Sep 2019 00:10:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXqWwipKZlbNXuE5nSmvPfMz0PF4ACL32nLVeD8IPCXyUeFRzLXRsOGRhumPNt++A4TAfHVA==
X-Received: by 2002:a17:90a:8087:: with SMTP id c7mr3941869pjn.59.1568185840666;
        Wed, 11 Sep 2019 00:10:40 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j10sm1573091pjn.3.2019.09.11.00.10.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 00:10:39 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 3/7] mm: Introduce FAULT_FLAG_INTERRUPTIBLE
Date: Wed, 11 Sep 2019 15:10:03 +0800
Message-Id: <20190911071007.20077-4-peterx@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190911071007.20077-1-peterx@redhat.com>
References: <20190911071007.20077-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

handle_userfaultfd() is currently the only one place in the kernel
page fault procedures that can respond to non-fatal userspace signals.
It was trying to detect such an allowance by checking against USER &
KILLABLE flags, which was "un-official".

In this patch, we introduced a new flag (FAULT_FLAG_INTERRUPTIBLE) to
show that the fault handler allows the fault procedure to respond even
to non-fatal signals.  Meanwhile, add this new flag to the default
fault flags so that all the page fault handlers can benefit from the
new flag.  With that, replacing the userfault check to this one.

Since the line is getting even longer, clean up the fault flags a bit
too to ease TTY users.

Although we've got a new flag and applied it, we shouldn't have any
functional change with this patch so far.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c   |  4 +---
 include/linux/mm.h | 39 ++++++++++++++++++++++++++++-----------
 2 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ccbdbd62f0d8..4a8ad2dc2b6f 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -462,9 +462,7 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, uns=
igned long reason)
 	uwq.ctx =3D ctx;
 	uwq.waken =3D false;
=20
-	return_to_userland =3D
-		(vmf->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) =3D=3D
-		(FAULT_FLAG_USER|FAULT_FLAG_KILLABLE);
+	return_to_userland =3D vmf->flags & FAULT_FLAG_INTERRUPTIBLE;
 	blocking_state =3D return_to_userland ? TASK_INTERRUPTIBLE :
 			 TASK_KILLABLE;
=20
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 57fb5c535f8e..53ec7abb8472 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -383,22 +383,38 @@ extern unsigned int kobjsize(const void *objp);
  */
 extern pgprot_t protection_map[16];
=20
-#define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
-#define FAULT_FLAG_MKWRITE	0x02	/* Fault was mkwrite of existing pte */
-#define FAULT_FLAG_ALLOW_RETRY	0x04	/* Retry fault if blocking */
-#define FAULT_FLAG_RETRY_NOWAIT	0x08	/* Don't drop mmap_sem and wait whe=
n retrying */
-#define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killabl=
e region */
-#define FAULT_FLAG_TRIED	0x20	/* Second try */
-#define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
-#define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
-#define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruc=
tion fetch */
+/**
+ * Fault flag definitions.
+ *
+ * @FAULT_FLAG_WRITE: Fault was a write fault.
+ * @FAULT_FLAG_MKWRITE: Fault was mkwrite of existing PTE.
+ * @FAULT_FLAG_ALLOW_RETRY: Allow to retry the fault if blocked.
+ * @FAULT_FLAG_RETRY_NOWAIT: Don't drop mmap_sem and wait when retrying.
+ * @FAULT_FLAG_KILLABLE: The fault task is in SIGKILL killable region.
+ * @FAULT_FLAG_TRIED: The fault has been tried once.
+ * @FAULT_FLAG_USER: The fault originated in userspace.
+ * @FAULT_FLAG_REMOTE: The fault is not for current task/mm.
+ * @FAULT_FLAG_INSTRUCTION: The fault was during an instruction fetch.
+ * @FAULT_FLAG_INTERRUPTIBLE: The fault can be interrupted by non-fatal =
signals.
+ */
+#define FAULT_FLAG_WRITE			0x01
+#define FAULT_FLAG_MKWRITE			0x02
+#define FAULT_FLAG_ALLOW_RETRY			0x04
+#define FAULT_FLAG_RETRY_NOWAIT			0x08
+#define FAULT_FLAG_KILLABLE			0x10
+#define FAULT_FLAG_TRIED			0x20
+#define FAULT_FLAG_USER				0x40
+#define FAULT_FLAG_REMOTE			0x80
+#define FAULT_FLAG_INSTRUCTION  		0x100
+#define FAULT_FLAG_INTERRUPTIBLE		0x200
=20
 /*
  * The default fault flags that should be used by most of the
  * arch-specific page fault handlers.
  */
 #define FAULT_FLAG_DEFAULT  (FAULT_FLAG_ALLOW_RETRY | \
-			     FAULT_FLAG_KILLABLE)
+			     FAULT_FLAG_KILLABLE | \
+			     FAULT_FLAG_INTERRUPTIBLE)
=20
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
@@ -409,7 +425,8 @@ extern pgprot_t protection_map[16];
 	{ FAULT_FLAG_TRIED,		"TRIED" }, \
 	{ FAULT_FLAG_USER,		"USER" }, \
 	{ FAULT_FLAG_REMOTE,		"REMOTE" }, \
-	{ FAULT_FLAG_INSTRUCTION,	"INSTRUCTION" }
+	{ FAULT_FLAG_INSTRUCTION,	"INSTRUCTION" }, \
+	{ FAULT_FLAG_INTERRUPTIBLE,	"INTERRUPTIBLE" }
=20
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma=
's
--=20
2.21.0


