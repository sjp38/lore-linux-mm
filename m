Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9166B007E
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:34 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id l68so121856250wml.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 05:42:34 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id x13si26178579wjw.168.2016.03.20.05.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 05:42:33 -0700 (PDT)
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rapoport@il.ibm.com>;
	Sun, 20 Mar 2016 12:42:32 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id DEC582190046
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:42:10 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2KCgTsI1704328
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:42:29 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2KCgS2L016883
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:28 -0400
From: Mike Rapoport <rapoport@il.ibm.com>
Subject: [PATCH 0/5] userfaultfd: extension for non cooperative uffd usage
Date: Sun, 20 Mar 2016 14:42:16 +0200
Message-Id: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>, Mike Rapoport <rapoport@il.ibm.com>

Hi,

This set is to address the issues that appear in userfaultfd usage
scenarios when the task monitoring the uffd and the mm-owner do not 
cooperate to each other on VM changes such as remaps, madvises and 
fork()-s.

The pacthes are essentially the same as in the prevoious respin (1),
they've just been rebased on the current tree.

[1] http://thread.gmane.org/gmane.linux.kernel.mm/132662

Pavel Emelyanov (5):
  uffd: Split the find_userfault() routine
  uffd: Add ability to report non-PF events from uffd descriptor
  uffd: Add fork() event
  uffd: Add mremap() event
  uffd: Add madvise() event for MADV_DONTNEED request

 fs/userfaultfd.c                 | 319 ++++++++++++++++++++++++++++++++++++++-
 include/linux/userfaultfd_k.h    |  41 +++++
 include/uapi/linux/userfaultfd.h |  28 +++-
 kernel/fork.c                    |  10 +-
 mm/madvise.c                     |   2 +
 mm/mremap.c                      |  17 ++-
 6 files changed, 395 insertions(+), 22 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
