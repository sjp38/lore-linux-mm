Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFD40ECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:11:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F99B2084D
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:11:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F99B2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A74F6B000E; Wed, 11 Sep 2019 03:11:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 458386B0010; Wed, 11 Sep 2019 03:11:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36DF66B0266; Wed, 11 Sep 2019 03:11:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id 12F1A6B000E
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:11:10 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A9139824CA3F
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:11:09 +0000 (UTC)
X-FDA: 75921768258.18.foot57_7e7cfeebe4c32
X-HE-Tag: foot57_7e7cfeebe4c32
X-Filterd-Recvd-Size: 5913
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:11:09 +0000 (UTC)
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2DA392BF7B
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:11:08 +0000 (UTC)
Received: by mail-pf1-f200.google.com with SMTP id w126so13725125pfd.22
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 00:11:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=5V3o75iQXkQgVY+0z1NoQ3FPIfgARTaoPLE+FPdZTuk=;
        b=JN2+t9H7QpHIeyAh+v36k7yew9aMRzAjoYH/VnLPrcjOjqX3/jRGp7Bn1gqOVZE/Ro
         2TLpUORItkakBEzFMxWaJfuXRblPligLcVyuTVxMidD015M1VtcH4kXrNJ3ri2OWWKbQ
         zGXjxmScdn+hUJJHIkO5bSKmREg5KEQJdk85pFqslqqJY6qqNzvYbWyMhVy3iNbPbzs7
         sWiOphYvrzABDOtDsE223i6e65EqavnpcFN19H+71O4p1BYkv4F9PDQ0RQBSS15RqUum
         WxlAm1Geqk1ZI7l4ZZhfBM7WARL20G2RjrxSMcdSN/pW+a31PnlhgVb6lQ26LmclLVUk
         YQUw==
X-Gm-Message-State: APjAAAX2qAYEHCf7x8vJ5A/22GuIvtHbaFIncGcco0D1UkjzGEBUsgAj
	IvShiFXxpPeGa5LrUPJdV1thBHxyxE0mf7U+zLdymPL3IOG898BwCoxPqL8UM6bt0UQypCIkh4I
	O/DTUYxyjIxM=
X-Received: by 2002:a17:902:ac8d:: with SMTP id h13mr34358542plr.273.1568185867165;
        Wed, 11 Sep 2019 00:11:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBWqs9OHiqcVYnHixJfPeceFNFutrglNZt9VPFbnaRBihSuzuUiLIbWkefUjaIZNUHaxC65A==
X-Received: by 2002:a17:902:ac8d:: with SMTP id h13mr34358534plr.273.1568185867006;
        Wed, 11 Sep 2019 00:11:07 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j10sm1573091pjn.3.2019.09.11.00.11.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 00:11:06 -0700 (PDT)
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
Subject: [PATCH v3 7/7] mm/gup: Allow VM_FAULT_RETRY for multiple times
Date: Wed, 11 Sep 2019 15:10:07 +0800
Message-Id: <20190911071007.20077-8-peterx@redhat.com>
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
+			goto out;
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


