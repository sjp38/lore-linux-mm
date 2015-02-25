Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5A61D6B006C
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:58:55 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id vb8so6954639obc.12
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:58:55 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id ux6si2943016obc.107.2015.02.25.13.58.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 13:58:54 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH -part2 0/3] mm: improve handling of mm->exe_file
Date: Wed, 25 Feb 2015 13:58:34 -0800
Message-Id: <1424901517-25069-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net

This set addresses exe_file use for users that require the mmap_sem
for other things (mostly looking up the related vma->vm_file). In
a lot of cases we end up with scenarios where we take the mmap_sem in
get_mm_exe_file(), just to then take it again soon after. This is only
temporary as we will remove the need for mmap_sem when dealing with
exe_file.

Applies on top of linux-next (-20150225). The arch bits are entirely
100% untested, so I apologize if there are any stupid build issues.

Thanks!

Davidlohr Bueso (3):
  tile/elf: reorganize notify_exec()
  oprofile: reduce mmap_sem hold for mm->exe_file
  powerpc/oprofile: reduce mmap_sem hold for exe_file

 arch/powerpc/oprofile/cell/spu_task_sync.c | 13 +++++----
 arch/tile/mm/elf.c                         | 47 ++++++++++++++++++------------
 drivers/oprofile/buffer_sync.c             | 30 ++++++++++---------
 3 files changed, 53 insertions(+), 37 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
