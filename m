Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5646B01F2
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:44:44 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o31JigLI014504
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:44:42 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by kpbe20.cbf.corp.google.com with ESMTP id o31JhZSQ008083
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:44:30 -0700
Received: by pvg12 with SMTP id 12so668209pvg.24
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:44:27 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:44:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 0/5] oom: fixes and cleanup
Message-ID: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset fixes a couple of issues with the oom killer, namely
tasklist_lock locking requirements and sending SIGKILLs to already
exiting tasks.  It also cleans up a couple functions, __oom_kill_task()
and oom_badness().

This patchset is based on mmotm-2010-03-24-14-48.

Many thanks to Oleg Nesterov <oleg@redhat.com> for interest in this work.
---
 fs/proc/base.c      |    5 +---
 include/linux/oom.h |    2 +-
 mm/oom_kill.c       |   58 ++++++++++++++++++++++-----------------------------
 3 files changed, 27 insertions(+), 38 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
