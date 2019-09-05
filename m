Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A858C3A5AB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE1BD2184B
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE1BD2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 837D26B027E; Thu,  5 Sep 2019 06:16:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E8B46B027F; Thu,  5 Sep 2019 06:16:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B1076B0280; Thu,  5 Sep 2019 06:16:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0108.hostedemail.com [216.40.44.108])
	by kanga.kvack.org (Postfix) with ESMTP id 4C36C6B027E
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:16:27 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E0A3F181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:26 +0000 (UTC)
X-FDA: 75900462372.21.range91_555322c15283b
X-HE-Tag: range91_555322c15283b
X-Filterd-Recvd-Size: 5676
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:26 +0000 (UTC)
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 62D6183F51
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:25 +0000 (UTC)
Received: by mail-pf1-f198.google.com with SMTP id z23so1493762pfn.0
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 03:16:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=SCWgxmciM/l530v7wrFJtbFp6IYoQ8sTPq58RJeE1HI=;
        b=Q4NeZsSa037Lg7Yt3JPR/lre3X1+djUN/NhH5FoPGazSSxlLUaEFrFXp6FBr5BnPkt
         q/s3q5IpStj8qLHY2CRUOyx7ZhJZooyysc4PBOGk2e8icNY0gp/hKx6weQeOUJ46nuFi
         VGsBVGq29wBNl7q+7VF/4ZroHGc/pviCXHm9Vdo/QEfax58Wi2QJOOdho+4ZdxNi1RF2
         SF5q1a3XYgPzMscsbY6fqVc3PPpOcvSqMygocvgYBuDsX7wiB2e0SdnKK6e9Ays4Dd9B
         b9GPTvIO8tKpvfcnYG0VeYo5eOtUS87Dp4CY1+7H7GN5v9hLvkXMImyDi17dRYSoHFPj
         NZRw==
X-Gm-Message-State: APjAAAVz9dXk40qSaLtEZeZg9lRNh/o6/1Qj3q3yZ79oqb599g+J8/nl
	qpYvzlFdmPYj0dZ/EgCqJNTs7ARgF17Qga2lHnBX+iN45ycj803nZahTZz8CQbAFlmRykUH7yvS
	iwUERWMMbZaI=
X-Received: by 2002:a17:902:988a:: with SMTP id s10mr2410544plp.119.1567678584563;
        Thu, 05 Sep 2019 03:16:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySfDc/zhOFXj3cLsVFTtpVlLwUaGTCQLDhWRP0rJ8KpSGAK+5oupbPfAYaTJR2LP4bgKauaA==
X-Received: by 2002:a17:902:988a:: with SMTP id s10mr2410525plp.119.1567678584389;
        Thu, 05 Sep 2019 03:16:24 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id a20sm413852pfo.33.2019.09.05.03.16.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 03:16:23 -0700 (PDT)
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
Subject: [PATCH v2 5/7] userfaultfd: Don't retake mmap_sem to emulate NOPAGE
Date: Thu,  5 Sep 2019 18:15:32 +0800
Message-Id: <20190905101534.9637-6-peterx@redhat.com>
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


