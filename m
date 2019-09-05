Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42F20C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1168121743
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1168121743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBA616B0282; Thu,  5 Sep 2019 06:16:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B44C96B0283; Thu,  5 Sep 2019 06:16:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0BA26B0284; Thu,  5 Sep 2019 06:16:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC6D6B0282
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:16:44 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E8676180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:43 +0000 (UTC)
X-FDA: 75900463086.25.books08_57d109e4dd215
X-HE-Tag: books08_57d109e4dd215
X-Filterd-Recvd-Size: 5546
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:43 +0000 (UTC)
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7411AA76C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:42 +0000 (UTC)
Received: by mail-pl1-f198.google.com with SMTP id f5so1193885plr.0
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 03:16:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ZxGn2ZdCmZxu7XSt21NyGW/6BPjnqeicp2jG9/gg754=;
        b=WoT+nbSRcEJNvkKy7IoJgqONvgAZGEDLkpxYPb8T0AzgIajjpkwsUGYTwbPN4afMTA
         8dW1Yx8WNMWY0RqrgCOCO8+L4c26xywOFSgiDJuIGW6f/DfX3eUt8kWjNPeVuAhUzWLy
         XqGHB5G63JKjaY7kkEyY4HtxMT5yAsyVrAdcIlsFG1fRG54JUCdEEjYKPat0HnCA8iRV
         9hcP2rxbQTRW8mqI2rG4kTy4r9uA//E4avyqC/Bb8Ry/E6NXhi0GhE2nQ6qbBBeF7e+H
         HzsHETRHsnxGTgy74BkbI9cUQ9tqLJmO3smn01gOJih3nFdhFqd6hmz3akZShZydEjOE
         MjrA==
X-Gm-Message-State: APjAAAVV1Mp4VSUx5dlc0m/RiL2x6/LsF/3x4r45hZ8hiFe3lDit0G6P
	co4ymO+uO7dm5/SKunRR7FbJn2HihPzUDdFiBIxIWbvR2TGFMXRFVb/ud9BHDlgYqmCdOm4Jo6E
	tHovLD9qudwU=
X-Received: by 2002:a63:4c5a:: with SMTP id m26mr2400208pgl.270.1567678601199;
        Thu, 05 Sep 2019 03:16:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKY6zyOi9KJwWuM85hdo9q/xf5YhRviK2C6aqVXRBBcdCiehlIc9Px5hIh14dORwxN2WooCg==
X-Received: by 2002:a63:4c5a:: with SMTP id m26mr2400188pgl.270.1567678600925;
        Thu, 05 Sep 2019 03:16:40 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id a20sm413852pfo.33.2019.09.05.03.16.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 03:16:39 -0700 (PDT)
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
Subject: [PATCH v2 7/7] mm/gup: Allow VM_FAULT_RETRY for multiple times
Date: Thu,  5 Sep 2019 18:15:34 +0800
Message-Id: <20190905101534.9637-8-peterx@redhat.com>
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

This is the gup counterpart of the change that allows the VM_FAULT_RETRY
to happen for more than once.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/gup.c     | 17 +++++++++++++----
 mm/hugetlb.c |  6 ++++--
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index eddbb95dcb8f..65d0b45be5c9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -644,7 +644,10 @@ static int faultin_page(struct task_struct *tsk, str=
uct vm_area_struct *vma,
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |=3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
 	if (*flags & FOLL_TRIED) {
-		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
+		/*
+		 * Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED
+		 * can co-exist
+		 */
 		fault_flags |=3D FAULT_FLAG_TRIED;
 	}
=20
@@ -1059,17 +1062,23 @@ static __always_inline long __get_user_pages_lock=
ed(struct task_struct *tsk,
 		if (likely(pages))
 			pages +=3D ret;
 		start +=3D ret << PAGE_SHIFT;
+		lock_dropped =3D true;
=20
+retry:
 		/*
 		 * Repeat on the address that fired VM_FAULT_RETRY
-		 * without FAULT_FLAG_ALLOW_RETRY but with
+		 * with both FAULT_FLAG_ALLOW_RETRY and
 		 * FAULT_FLAG_TRIED.
 		 */
 		*locked =3D 1;
-		lock_dropped =3D true;
 		down_read(&mm->mmap_sem);
 		ret =3D __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, locked);
+		if (!*locked) {
+			/* Continue to retry until we succeeded */
+			BUG_ON(ret !=3D 0);
+			goto retry;
+		}
 		if (ret !=3D 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5f816ee42206..6b9d27925e7a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4328,8 +4328,10 @@ long follow_hugetlb_page(struct mm_struct *mm, str=
uct vm_area_struct *vma,
 				fault_flags |=3D FAULT_FLAG_ALLOW_RETRY |
 					FAULT_FLAG_RETRY_NOWAIT;
 			if (flags & FOLL_TRIED) {
-				VM_WARN_ON_ONCE(fault_flags &
-						FAULT_FLAG_ALLOW_RETRY);
+				/*
+				 * Note: FAULT_FLAG_ALLOW_RETRY and
+				 * FAULT_FLAG_TRIED can co-exist
+				 */
 				fault_flags |=3D FAULT_FLAG_TRIED;
 			}
 			ret =3D hugetlb_fault(mm, vma, vaddr, fault_flags);
--=20
2.21.0


