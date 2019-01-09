Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A58D8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 21:02:10 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id y27so4866200qkj.21
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 18:02:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u11si3629933qvl.90.2019.01.08.18.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 18:02:09 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] mm/hugetlb.c: teach follow_hugetlb_page() to handle FOLL_NOWAIT
Date: Tue,  8 Jan 2019 21:02:02 -0500
Message-Id: <20190109020203.26669-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

Hello,

this fixes a regression that resurfaced in hugetlbfs code after we
fixed it for the core VM a few months ago. This is only reproducible
doing postcopy live migration of KVM (the only user of FOLL_NOWAIT) if
backed by hugetlbfs memory. It's unrelated to userfaultfd, but
userfaultfd reproduces it easily because it's an heavy user of
VM_FAULT_RETRY retvals.

Thanks,
Andrea

Andrea Arcangeli (1):
  mm/hugetlb.c: teach follow_hugetlb_page() to handle FOLL_NOWAIT

 mm/hugetlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
