Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53EC4C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 206AD21883
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 206AD21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1E536B027C; Thu,  5 Sep 2019 06:16:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF77F6B027D; Thu,  5 Sep 2019 06:16:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0B196B027E; Thu,  5 Sep 2019 06:16:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0074.hostedemail.com [216.40.44.74])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE9D6B027C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:16:12 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0B49733C4
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:12 +0000 (UTC)
X-FDA: 75900461784.04.drain43_532c29924f82c
X-HE-Tag: drain43_532c29924f82c
X-Filterd-Recvd-Size: 7669
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:11 +0000 (UTC)
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A32618830A
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:10 +0000 (UTC)
Received: by mail-pf1-f200.google.com with SMTP id i28so1457979pfq.16
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 03:16:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=RRZuHtIpu1kWmysN8fGt73f3ShagvK1FUD0BwRzbsQk=;
        b=j41dRbh9XwWL+3QqjWmd1c8Cw/FF0MDqx1ompgrCP6mmePeFKoNG+IV5iUwYXk/7ZH
         L1kM/tq/URrDEJffynv1MckNgUKgq9PR10tnFPc7sZ3WGPVAcG4EWQSEwaPQnbwGYXQb
         pHEmd2JsyGakQ1qrwCOA4zmjf8f7cE9gyCZlJMHigznwCWf6JOSgtEplMvtPELVYHF5H
         MuJ+xHXaNB3NnFe5sMJX5WC1FdfS7AZhxrw8Y2tydrceezewZTzi/0g/0UBsaAelyeVV
         1XjUfaYYnh16TycuYZWg+OU9PWpaHTxu5fvJSaKC/xQNHC3punGqft6sx3nveOno3Ijs
         w7PA==
X-Gm-Message-State: APjAAAWtRHXb0J+KPqCj5SLmU5Cf7KxDB/1UUsf3L8rIs0aqLemJkcGz
	ZQ73iE/jKzXuC+f5WF1hLDkUlCq01u2Aui9OstDZf3ObsJONrz3uo+i+25gXDcGyGdjNLGwnnWS
	vMelCsg5zdE8=
X-Received: by 2002:aa7:81c1:: with SMTP id c1mr2745048pfn.78.1567678569689;
        Thu, 05 Sep 2019 03:16:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQCYkfTar4nbC5tmBvHetw7MAXc9iDUbBdhXHz/m1fjU6zuFE95xDQuiuJUT/a/K9eLrCiTw==
X-Received: by 2002:aa7:81c1:: with SMTP id c1mr2745012pfn.78.1567678569455;
        Thu, 05 Sep 2019 03:16:09 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id a20sm413852pfo.33.2019.09.05.03.16.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 03:16:08 -0700 (PDT)
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
Subject: [PATCH v2 3/7] mm: Introduce FAULT_FLAG_INTERRUPTIBLE
Date: Thu,  5 Sep 2019 18:15:30 +0800
Message-Id: <20190905101534.9637-4-peterx@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190905101534.9637-1-peterx@redhat.com>
References: <20190905101534.9637-1-peterx@redhat.com>
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


