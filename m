Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 669EC6B0095
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 18:39:48 -0400 (EDT)
Received: by oiaz123 with SMTP id z123so11944366oia.3
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 15:39:48 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id t3si1069758obf.73.2015.03.14.15.39.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 15:39:47 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file serialization
Date: Sat, 14 Mar 2015 15:39:22 -0700
Message-Id: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, gorcunov@openvz.org, oleg@redhat.com, koct9i@gmail.com, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a set I created on top of patch 1/4 which also includes mm_struct cleanups
and dealing with prctl exe_file functionality. Specific details are in each patch.
Patch 4 is an extra trivial one I found while going through the code.

Applies on top of next-20150313.

Thanks!

Davidlohr Bueso (4):
  mm: replace mmap_sem for mm->exe_file serialization
  mm: introduce struct exe_file
  prctl: move MMF_EXE_FILE_CHANGED into exe_file struct
  kernel/fork: use pr_alert() for rss counter bugs

 fs/exec.c                |   6 +++
 include/linux/mm.h       |   4 ++
 include/linux/mm_types.h |   8 +++-
 include/linux/sched.h    |   5 +--
 kernel/fork.c            |  72 ++++++++++++++++++++++++++------
 kernel/sys.c             | 106 +++++++++++++++++++++++++++--------------------
 6 files changed, 141 insertions(+), 60 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
