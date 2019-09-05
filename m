Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 465EEC3A5AA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA83F2184B
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:15:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA83F2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AEAC6B027A; Thu,  5 Sep 2019 06:15:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85E3A6B027B; Thu,  5 Sep 2019 06:15:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 773526B027C; Thu,  5 Sep 2019 06:15:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id 540B06B027A
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:15:59 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 016F1180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:15:59 +0000 (UTC)
X-FDA: 75900461238.14.plant36_5137a00cc5331
X-HE-Tag: plant36_5137a00cc5331
X-Filterd-Recvd-Size: 11148
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:15:57 +0000 (UTC)
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 040B2882EA
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:15:57 +0000 (UTC)
Received: by mail-pf1-f198.google.com with SMTP id x10so1453166pfr.20
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 03:15:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=U6jD3QrhOaKmK0EuyaVvKU+JdqlKP+u0W9Mccju17fc=;
        b=htfhj+IYscmbxxY0SLCs9w0cqqV1R+sCOSKOxI5eAz0TtrVCZIBUl6yjunodMzqWGO
         RyJCv7K3KGt+GrZu5Q11rMiSuUgji3wX2phLJJ0Uq2wIe/Yl1BDeuUuqEHgTClW7GeNK
         Z6TjxCknu30+/EK+tpXJlD5aThK1iFGR+kvdC+MsB3lf3QhW5VXyqstcEYd9IyCzrGc6
         6AW75jgG64X0tqDBF7Ie2+EaUQFSItalI2Qi31r/8O0o5C2u9GdoTmNaA7BxSELhf4o8
         mBIHkLhstEw1F6IuWHtiHLdlJKXtMOBsMcafpGFjmnJnSKo6tKruXQviNbZKjBiwtcGR
         oOfQ==
X-Gm-Message-State: APjAAAWlMNFjTm/967u9YqXqw7DASO/MteDxy7z+EIUDjR9Yxh2RGvha
	zKczvCBPyJwz64VNs6jpPybKxa+BmTqZgZuyqMWGoRqkhtHNNJdS0DyNDxQbvc8HLVQxvpqUd1H
	Tr55bDGHUV9w=
X-Received: by 2002:a62:ee0e:: with SMTP id e14mr2873486pfi.31.1567678556101;
        Thu, 05 Sep 2019 03:15:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLZrMDTh45FeN+eUEDYn/HUog7bmtWQpvM3Fo3USpydbbe3iJMJ/OqTwL2izDvJ0YR0cnVLQ==
X-Received: by 2002:a62:ee0e:: with SMTP id e14mr2873454pfi.31.1567678555825;
        Thu, 05 Sep 2019 03:15:55 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id a20sm413852pfo.33.2019.09.05.03.15.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 03:15:55 -0700 (PDT)
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
Subject: [PATCH v2 1/7] mm/gup: Rename "nonblocking" to "locked" where proper
Date: Thu,  5 Sep 2019 18:15:28 +0800
Message-Id: <20190905101534.9637-2-peterx@redhat.com>
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

There's plenty of places around __get_user_pages() that has a parameter
"nonblocking" which does not really mean that "it won't block" (because
it can really block) but instead it shows whether the mmap_sem is
released by up_read() during the page fault handling mostly when
VM_FAULT_RETRY is returned.

We have the correct naming in e.g. get_user_pages_locked() or
get_user_pages_remote() as "locked", however there're still many places
that are using the "nonblocking" as name.

Renaming the places to "locked" where proper to better suite the
functionality of the variable.  While at it, fixing up some of the
comments accordingly.

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/gup.c     | 44 +++++++++++++++++++++-----------------------
 mm/hugetlb.c |  8 ++++----
 2 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bac..eddbb95dcb8f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -622,12 +622,12 @@ static int get_gate_page(struct mm_struct *mm, unsi=
gned long address,
 }
=20
 /*
- * mmap_sem must be held on entry.  If @nonblocking !=3D NULL and
- * *@flags does not include FOLL_NOWAIT, the mmap_sem may be released.
- * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
+ * mmap_sem must be held on entry.  If @locked !=3D NULL and *@flags
+ * does not include FOLL_NOWAIT, the mmap_sem may be released.  If it
+ * is, *@locked will be set to 0 and -EBUSY returned.
  */
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *=
vma,
-		unsigned long address, unsigned int *flags, int *nonblocking)
+		unsigned long address, unsigned int *flags, int *locked)
 {
 	unsigned int fault_flags =3D 0;
 	vm_fault_t ret;
@@ -639,7 +639,7 @@ static int faultin_page(struct task_struct *tsk, stru=
ct vm_area_struct *vma,
 		fault_flags |=3D FAULT_FLAG_WRITE;
 	if (*flags & FOLL_REMOTE)
 		fault_flags |=3D FAULT_FLAG_REMOTE;
-	if (nonblocking)
+	if (locked)
 		fault_flags |=3D FAULT_FLAG_ALLOW_RETRY;
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |=3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
@@ -665,8 +665,8 @@ static int faultin_page(struct task_struct *tsk, stru=
ct vm_area_struct *vma,
 	}
=20
 	if (ret & VM_FAULT_RETRY) {
-		if (nonblocking && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
-			*nonblocking =3D 0;
+		if (locked && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
+			*locked =3D 0;
 		return -EBUSY;
 	}
=20
@@ -743,7 +743,7 @@ static int check_vma_flags(struct vm_area_struct *vma=
, unsigned long gup_flags)
  *		only intends to ensure the pages are faulted in.
  * @vmas:	array of pointers to vmas corresponding to each page.
  *		Or NULL if the caller does not require them.
- * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ * @locked:     whether we're still with the mmap_sem held
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -772,13 +772,11 @@ static int check_vma_flags(struct vm_area_struct *v=
ma, unsigned long gup_flags)
  * appropriate) must be called after the page is finished with, and
  * before put_page is called.
  *
- * If @nonblocking !=3D NULL, __get_user_pages will not wait for disk IO
- * or mmap_sem contention, and if waiting is needed to pin all pages,
- * *@nonblocking will be set to 0.  Further, if @gup_flags does not
- * include FOLL_NOWAIT, the mmap_sem will be released via up_read() in
- * this case.
+ * If @locked !=3D NULL, *@locked will be set to 0 when mmap_sem is
+ * released by an up_read().  That can happen if @gup_flags does not
+ * have FOLL_NOWAIT.
  *
- * A caller using such a combination of @nonblocking and @gup_flags
+ * A caller using such a combination of @locked and @gup_flags
  * must therefore hold the mmap_sem for reading only, and recognize
  * when it's been released.  Otherwise, it must be held for either
  * reading or writing and will not be released.
@@ -790,7 +788,7 @@ static int check_vma_flags(struct vm_area_struct *vma=
, unsigned long gup_flags)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *=
mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+		struct vm_area_struct **vmas, int *locked)
 {
 	long ret =3D 0, i =3D 0;
 	struct vm_area_struct *vma =3D NULL;
@@ -834,7 +832,7 @@ static long __get_user_pages(struct task_struct *tsk,=
 struct mm_struct *mm,
 			if (is_vm_hugetlb_page(vma)) {
 				i =3D follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
-						gup_flags, nonblocking);
+						gup_flags, locked);
 				continue;
 			}
 		}
@@ -852,7 +850,7 @@ static long __get_user_pages(struct task_struct *tsk,=
 struct mm_struct *mm,
 		page =3D follow_page_mask(vma, start, foll_flags, &ctx);
 		if (!page) {
 			ret =3D faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+					   locked);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -1178,7 +1176,7 @@ EXPORT_SYMBOL(get_user_pages_remote);
  * @vma:   target vma
  * @start: start address
  * @end:   end address
- * @nonblocking:
+ * @locked: whether the mmap_sem is still held
  *
  * This takes care of mlocking the pages too if VM_LOCKED is set.
  *
@@ -1186,14 +1184,14 @@ EXPORT_SYMBOL(get_user_pages_remote);
  *
  * vma->vm_mm->mmap_sem must be held.
  *
- * If @nonblocking is NULL, it may be held for read or write and will
+ * If @locked is NULL, it may be held for read or write and will
  * be unperturbed.
  *
- * If @nonblocking is non-NULL, it must held for read only and may be
- * released.  If it's released, *@nonblocking will be set to 0.
+ * If @locked is non-NULL, it must held for read only and may be
+ * released.  If it's released, *@locked will be set to 0.
  */
 long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking)
+		unsigned long start, unsigned long end, int *locked)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	unsigned long nr_pages =3D (end - start) / PAGE_SIZE;
@@ -1228,7 +1226,7 @@ long populate_vma_page_range(struct vm_area_struct =
*vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, locked);
 }
=20
 /*
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ede7e7f5d1ab..5f816ee42206 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4251,7 +4251,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_=
mm,
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vm=
a,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
-			 long i, unsigned int flags, int *nonblocking)
+			 long i, unsigned int flags, int *locked)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr =3D *position;
@@ -4322,7 +4322,7 @@ long follow_hugetlb_page(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
 				spin_unlock(ptl);
 			if (flags & FOLL_WRITE)
 				fault_flags |=3D FAULT_FLAG_WRITE;
-			if (nonblocking)
+			if (locked)
 				fault_flags |=3D FAULT_FLAG_ALLOW_RETRY;
 			if (flags & FOLL_NOWAIT)
 				fault_flags |=3D FAULT_FLAG_ALLOW_RETRY |
@@ -4339,9 +4339,9 @@ long follow_hugetlb_page(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
 				break;
 			}
 			if (ret & VM_FAULT_RETRY) {
-				if (nonblocking &&
+				if (locked &&
 				    !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
-					*nonblocking =3D 0;
+					*locked =3D 0;
 				*nr_pages =3D 0;
 				/*
 				 * VM_FAULT_RETRY must not return an
--=20
2.21.0


