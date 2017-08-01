Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BFD16B04DE
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 21:54:20 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id d29so1139841uai.14
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 18:54:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p16si9192981vkp.303.2017.07.31.18.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 18:54:18 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [RESEND PATCH v3 0/2] userfaultfd: selftest: Add tests for UFFD_FEATURE_SIGBUS feature
Date: Mon, 31 Jul 2017 21:54:04 -0400
Message-Id: <1501552446-748335-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: aarcange@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

Resending, Andrew asked if I could resend the whole set.
Just added 'Reviewed-by' to commit log for 1/2, no other
changes.

v3 patch for 2/2 as before
http://marc.info/?l=linux-mm&m=150148267803458&w=2

Previous patch set here:
http://marc.info/?l=linux-mm&m=150095815413275&w=2

Prakash Sangappa (2):
  userfaultfd: Add feature to request for a signal delivery
  userfaultfd: selftest: Add tests for UFFD_FEATURE_SIGBUS feature

 fs/userfaultfd.c                         |    3 +
 include/uapi/linux/userfaultfd.h         |   10 ++-
 tools/testing/selftests/vm/userfaultfd.c |  127 +++++++++++++++++++++++++++++-
 3 files changed, 136 insertions(+), 4 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
