Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEDFB6B0286
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 00:27:07 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c76so3141099qke.19
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 21:27:07 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j22sor780017qkk.137.2018.02.21.21.27.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 21:27:06 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 21 Feb 2018 21:26:57 -0800
Message-Id: <20180222052659.106016-1-dancol@google.com>
Subject: [PATCH 0/2] smaps bugfixes, new fields for locked memory
From: Daniel Colascione <dancol@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Daniel Colascione <dancol@google.com>

This small patch series fixes a few bugs in smaps_rollup, then adds
two new status fields that provide information about locked
memory sizes.

Daniel Colascione (2):
  Bug fixes for smaps_rollup
  Add LockedRss/LockedPrivate to smaps and smaps_rollup

 Documentation/filesystems/proc.txt |   7 +-
 fs/proc/task_mmu.c                 | 118 +++++++++++++++++++----------
 2 files changed, 83 insertions(+), 42 deletions(-)

-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
