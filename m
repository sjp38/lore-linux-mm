Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 592F16B004D
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:59:52 -0400 (EDT)
Received: by ewy28 with SMTP id 28so331386ewy.14
        for <linux-mm@kvack.org>; Thu, 02 Sep 2010 06:59:50 -0700 (PDT)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH 0/2 RESEND] 
Date: Thu,  2 Sep 2010 14:59:43 +0100
Message-Id: <1283435985-21934-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

This patch set is a resubmit of several patches I sent out earlier that adds
trace points to the mmap family.  These events report addresses and sizes when
each function returns success.  They will be used by a userspace tool that will
model memory usage.

Changes from V1:
- Group mmap, munmap, and brk into first patch (all in mmap.c) and mremap into
  second (in mremap.c)
- Use DEFINE_EVENT_CLASS and DEFINE_EVENT for mmap and brk events


Eric B Munson (2):
  Add trace points to mmap, munmap, and brk
  Add mremap trace point

 include/trace/events/mm.h |   97 +++++++++++++++++++++++++++++++++++++++++++++
 mm/mmap.c                 |   15 ++++++-
 mm/mremap.c               |    4 ++
 3 files changed, 115 insertions(+), 1 deletions(-)
 create mode 100644 include/trace/events/mm.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
