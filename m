Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD7CCC49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 09:46:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D404206CD
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 09:46:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D404206CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25EB86B0005; Wed, 11 Sep 2019 05:46:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20F676B0006; Wed, 11 Sep 2019 05:46:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FDF76B0007; Wed, 11 Sep 2019 05:46:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0005.hostedemail.com [216.40.44.5])
	by kanga.kvack.org (Postfix) with ESMTP id D990D6B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 05:46:11 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7B2EC824CA3B
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 09:46:11 +0000 (UTC)
X-FDA: 75922158942.27.frame30_18e77194b2d38
X-HE-Tag: frame30_18e77194b2d38
X-Filterd-Recvd-Size: 5880
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 09:46:11 +0000 (UTC)
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 143B5C056808
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 09:46:10 +0000 (UTC)
Received: by mail-pg1-f200.google.com with SMTP id p192so3652279pgp.11
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 02:46:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=aGQLRgm7G2kTyYY3bxXh1HW8rTy0El4wjuzgSvgBfMw=;
        b=eO1OmMt9EaZtOIRMjXJnK9CphSsvuagUVOIGbSQgxbM4/jXGA5wXTMHbWo2V89ZG9E
         uWEpsXILMYFlhgKxTUzSjP5mwPqapuGGaMwgIPea0auHtIecWyzqTXmxWL1b8NIzY1cQ
         DEMWgigHwodOf6Vo42wN1dfcKwIvwQJ36zlfT+vpGwfwS0WgWHAYtZ7QLWw5IvaGLcsm
         Nc8MQ6updeM0Nsg3zeM6VPKzRLHWScACsl1BzmIJTeiulrgNXGzX7EWg4UFpqpSRkVXa
         zjSgLGMNHsWc+wB/VOaOkCmhC1fF1DUzbL/2rRQKffJiOyGX3VU9veQ8B/wNpstOaPfI
         Kl0Q==
X-Gm-Message-State: APjAAAX7IUZQwhwqTF5XuLEA7cUNtbpWnEqs9oyQfHLyEBWR5lke9OXD
	yc0iiv6MjJFR9OQsiETHGOzz5LGVjU4Ihv8t3asGun8cpnFUHtMghqrnsfCGVLF7P4kadjbDb+I
	wWjyNxup4OkI=
X-Received: by 2002:a17:90b:8d7:: with SMTP id ds23mr4268283pjb.141.1568195169015;
        Wed, 11 Sep 2019 02:46:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLp2sZfcawkJJYszjOJIQ4z7kr7IN7Q37DCMo9yfe4m+hzrzukPqOTG4qN8IJMbHZpOAm2IA==
X-Received: by 2002:a17:90b:8d7:: with SMTP id ds23mr4268232pjb.141.1568195168646;
        Wed, 11 Sep 2019 02:46:08 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j7sm21610436pfi.96.2019.09.11.02.46.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 02:46:07 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Peter Xu <peterx@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
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
Subject: [PATCH v3.1 7/7] mm/gup: Allow VM_FAULT_RETRY for multiple times
Date: Wed, 11 Sep 2019 17:45:55 +0800
Message-Id: <20190911094555.9180-1-peterx@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190911071007.20077-8-peterx@redhat.com>
References: 
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is the gup counterpart of the change that allows the
VM_FAULT_RETRY to happen for more than once.  One thing to mention is
that we must check the fatal signal here before retry because the GUP
can be interrupted by that, otherwise we can loop forever.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/gup.c     | 25 ++++++++++++++++++++-----
 mm/hugetlb.c |  6 ++++--
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index eddbb95dcb8f..4b9413ee7b23 100644
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
@@ -1059,17 +1062,29 @@ static __always_inline long __get_user_pages_lock=
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
-		 * FAULT_FLAG_TRIED.
+		 * with both FAULT_FLAG_ALLOW_RETRY and
+		 * FAULT_FLAG_TRIED.  Note that GUP can be interrupted
+		 * by fatal signals, so we need to check it before we
+		 * start trying again otherwise it can loop forever.
 		 */
+
+		if (fatal_signal_pending(current))
+			break;
+
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
index 31c2a6275023..d0c98cff5b0f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4347,8 +4347,10 @@ long follow_hugetlb_page(struct mm_struct *mm, str=
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


