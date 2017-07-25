Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4B5E6B02B4
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 00:47:55 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id x35so98910034uax.11
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:47:55 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t22si5000138uae.315.2017.07.24.21.47.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 21:47:55 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [RESEND PATCH 0/2] userfaultfd: Add feature to request for a signal delivery
Date: Tue, 25 Jul 2017 00:47:40 -0400
Message-Id: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: aarcange@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

Hi Andrea, Mike,

Rsending - fixed email address. 

Here is the patch set for the proposed userfaultfd UFFD_FEATURE_SIGBUS
feature, including tests in selftest/vm/userfaultfd.c

Please review.

See following for previous discussion.

http://www.spinics.net/lists/linux-mm/msg129224.html
http://www.spinics.net/lists/linux-mm/msg130678.html


Thanks,

Prakash Sangappa (2):
  userfaultfd: Add feature to request for a signal delivery
  userfaultfd: selftest: Add tests for UFFD_FREATURE_SIGBUS

 fs/userfaultfd.c                         |    3 +
 include/uapi/linux/userfaultfd.h         |   10 ++-
 tools/testing/selftests/vm/userfaultfd.c |  121 +++++++++++++++++++++++++++++-
 3 files changed, 130 insertions(+), 4 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
