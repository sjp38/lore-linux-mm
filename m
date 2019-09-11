Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4D87ECDE27
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:10:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70DD82084D
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:10:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70DD82084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20FC86B000D; Wed, 11 Sep 2019 03:10:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C1066B000E; Wed, 11 Sep 2019 03:10:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AF126B0010; Wed, 11 Sep 2019 03:10:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id DBF296B000D
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:10:57 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6A5E7180AD802
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:57 +0000 (UTC)
X-FDA: 75921767754.08.eyes94_7cacebd49731f
X-HE-Tag: eyes94_7cacebd49731f
X-Filterd-Recvd-Size: 5672
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:56 +0000 (UTC)
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 704788535C
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:55 +0000 (UTC)
Received: by mail-pg1-f200.google.com with SMTP id q9so12161455pgv.17
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 00:10:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=SCWgxmciM/l530v7wrFJtbFp6IYoQ8sTPq58RJeE1HI=;
        b=BcqpuITVql5uPsd5QCUuWrmpRo0YtkmpCHDtAZqflV/qxvZ0EqfscpA2sPpzBzCipQ
         54jOER3dtrVfIvlbP+0X3+QIWfSzMoPayqQ6KvJp/S61SFrpgGP3it0VCfl04v16wYS5
         6aNJjGu3cYZwifng7LQS3O1aIPGghcWyaS9xTH59opwvQxknISQZxWHjAnB2qhzObYJx
         jTn247NycFhhCUABTw6ZXfxHIKmul6DgIWDVaFjNxpYCwEsznkc8IiS6hLGQ6ZPtee9V
         yaej0u7Fr6qC5t3R/KAkoHTJ2ge7rMBgHbk2nPfe9ecgOSAnf6y8wXKI/WgSJxRcot61
         l7yw==
X-Gm-Message-State: APjAAAVSOu/O0y33S7D8lePUPrZNt9zkiESWn2uriP5exj+VbZsMTX0J
	VR3MYtdILtJroReqkrGEYkslhraakz+fsTw7xQp93JyEX1gJ0DMlpQ003OKvik87NfME9q5OD+8
	lJgAqoo6PJEs=
X-Received: by 2002:a65:41c6:: with SMTP id b6mr31409834pgq.269.1568185854283;
        Wed, 11 Sep 2019 00:10:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaZ0K+GupwEKQ1pzKeVSBxX5TVirPii/f+DAFpTry982e3Pz4k9gUxwDbP6/093iBtczteUQ==
X-Received: by 2002:a65:41c6:: with SMTP id b6mr31409801pgq.269.1568185854002;
        Wed, 11 Sep 2019 00:10:54 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j10sm1573091pjn.3.2019.09.11.00.10.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 00:10:53 -0700 (PDT)
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
Subject: [PATCH v3 5/7] userfaultfd: Don't retake mmap_sem to emulate NOPAGE
Date: Wed, 11 Sep 2019 15:10:05 +0800
Message-Id: <20190911071007.20077-6-peterx@redhat.com>
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

The idea comes from the upstream discussion between Linus and Andrea:

https://lkml.org/lkml/2017/10/30/560

A summary to the issue: there was a special path in handle_userfault()
in the past that we'll return a VM_FAULT_NOPAGE when we detected
non-fatal signals when waiting for userfault handling.  We did that by
reacquiring the mmap_sem before returning.  However that brings a risk
in that the vmas might have changed when we retake the mmap_sem and
even we could be holding an invalid vma structure.

This patch removes the risk path in handle_userfault() then we will be
sure that the callers of handle_mm_fault() will know that the VMAs
might have changed.  Meanwhile with previous patch we don't lose
responsiveness as well since the core mm code now can handle the
nonfatal userspace signals quickly even if we return VM_FAULT_RETRY.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 4a8ad2dc2b6f..48b7ecf39f25 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -522,30 +522,6 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, un=
signed long reason)
=20
 	__set_current_state(TASK_RUNNING);
=20
-	if (return_to_userland) {
-		if (signal_pending(current) &&
-		    !fatal_signal_pending(current)) {
-			/*
-			 * If we got a SIGSTOP or SIGCONT and this is
-			 * a normal userland page fault, just let
-			 * userland return so the signal will be
-			 * handled and gdb debugging works.  The page
-			 * fault code immediately after we return from
-			 * this function is going to release the
-			 * mmap_sem and it's not depending on it
-			 * (unlike gup would if we were not to return
-			 * VM_FAULT_RETRY).
-			 *
-			 * If a fatal signal is pending we still take
-			 * the streamlined VM_FAULT_RETRY failure path
-			 * and there's no need to retake the mmap_sem
-			 * in such case.
-			 */
-			down_read(&mm->mmap_sem);
-			ret =3D VM_FAULT_NOPAGE;
-		}
-	}
-
 	/*
 	 * Here we race with the list_del; list_add in
 	 * userfaultfd_ctx_read(), however because we don't ever run
--=20
2.21.0


