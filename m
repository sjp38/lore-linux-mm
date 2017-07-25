Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7836B02B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 22:30:44 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q130so19103662qka.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:30:44 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v35si589920qtd.27.2017.07.24.19.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 19:30:43 -0700 (PDT)
From: prakash.sangappa@oracle.com
Subject: [PATCH 0/2] userfaultfd: Add feature to request for a signal delivery
Date: Mon, 24 Jul 2017 22:30:20 -0400
Message-Id: <1500949822-949266-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: inux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: aarcange@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@parallels.com, mike.kravetz@oracle.com

From: Prakash Sangappa <prakash.sangappa@oracle.com>

Hi Andrea, Mike,

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
