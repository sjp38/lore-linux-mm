Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3A821900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 09:38:11 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so70833718pdj.3
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 06:38:11 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id w14si15106526pbt.113.2015.06.06.06.38.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Jun 2015 06:38:10 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH -next 0/5] ipc: EIDRM/EINVAL returns & misc updates
Date: Sat,  6 Jun 2015 06:37:55 -0700
Message-Id: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

Patches 1,2: Are a resend, I've incorporated them to the set,
based on Manfred's comments.

Patch 3: is a trivial function rename.

Patches 4,5: are attempts to order how Linux ipc deals with EIDRM
and EINVAL return error codes. By looking at corresponding manpages
two possible inverted return codes are returned, these patches
make the manpages accurate now -- but I may have missed something,
and we are changing semantics. afaik EIDRM is specific to Linux
(other OSes only rely on EINVAL), which is already messy, so lets
try to make this consistent at least. 

Passes all ipc related ltp tests.

Thanks!

Davidlohr Bueso (5):
  ipc,shm: move BUG_ON check into shm_lock
  ipc,msg: provide barrier pairings for lockless receive
  ipc: rename ipc_obtain_object
  ipc,sysv: make return -EIDRM when racing with RMID consistent
  ipc,sysv: return -EINVAL upon incorrect id/seqnum

 ipc/msg.c  | 50 +++++++++++++++++++++++++++++++++++++++-----------
 ipc/sem.c  |  4 ++--
 ipc/shm.c  | 13 ++++++++-----
 ipc/util.c | 23 +++++++++++++----------
 ipc/util.h |  2 +-
 5 files changed, 63 insertions(+), 29 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
