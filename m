Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7698E0001
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 03:43:09 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g26-v6so11032360qkm.20
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 00:43:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s44-v6si223420qtk.382.2018.09.30.00.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Sep 2018 00:43:08 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH v2 0/3] userfaultfd: selftests: cleanups and trivial fixes
Date: Sun, 30 Sep 2018 15:42:56 +0800
Message-Id: <20180930074259.18229-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Shuah Khan <shuah@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Jerome Glisse <jglisse@redhat.com>, peterx@redhat.com, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kselftest@vger.kernel.org, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

v2:
- add a-bs
- add examples for non-anon tests [Mike]
- use brackets properly for nested ifs [Mike]

Recently I wrote some uffd write-protection test for the
not-yet-published uffd-wp tree, and I picked these common patches out
first for the selftest which even suite for master.

Any feedback is welcomed.  Please have a look, thanks.

Peter Xu (3):
  userfaultfd: selftest: cleanup help messages
  userfaultfd: selftest: generalize read and poll
  userfaultfd: selftest: recycle lock threads first

 tools/testing/selftests/vm/userfaultfd.c | 134 +++++++++++++----------
 1 file changed, 77 insertions(+), 57 deletions(-)

-- 
2.17.1
