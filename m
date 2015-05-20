Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 410596B0138
	for <linux-mm@kvack.org>; Wed, 20 May 2015 15:14:04 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so38590740qkg.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 12:14:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 65si1856675qks.95.2015.05.20.12.14.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 12:14:03 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/2] userfaultfdv4.1 update for -mm
Date: Wed, 20 May 2015 21:13:57 +0200
Message-Id: <1432149239-21760-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Hello,

Here some change I already folded earlier, extracted in order to apply
cleanly at the end of current -mm.

To fold the userfaultfd.txt update the part in "userfaultfd: change
the read API to return a uffd_msg" should also be extracted and folded
first or this one will reject.

Andrea Arcangeli (2):
  userfaultfd: documentation update
  userfaultfd: fs/userfaultfd.c add more comments

 Documentation/vm/userfaultfd.txt | 16 +++++++++-------
 fs/userfaultfd.c                 | 28 +++++++++++++++++++++++++++-
 2 files changed, 36 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
