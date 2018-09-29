Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0CD8E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 04:43:21 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b12-v6so7976558qtp.16
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 01:43:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s1-v6si1075677qkc.287.2018.09.29.01.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 01:43:20 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH 0/3] userfaultfd: selftests: cleanups and trivial fixes
Date: Sat, 29 Sep 2018 16:43:08 +0800
Message-Id: <20180929084311.15600-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Shuah Khan <shuah@kernel.org>, Jerome Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, peterx@redhat.com, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kselftest@vger.kernel.org, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Recently I wrote some uffd write-protection test for the
not-yet-published uffd-wp tree, and I picked these common patches out
first for the selftest which even suite for master.

Any feedback is welcomed.  Please have a look, thanks.

Peter Xu (3):
  userfaultfd: selftest: cleanup help messages
  userfaultfd: selftest: generalize read and poll
  userfaultfd: selftest: recycle lock threads first

 tools/testing/selftests/vm/userfaultfd.c | 131 +++++++++++++----------
 1 file changed, 74 insertions(+), 57 deletions(-)

-- 
2.17.1
