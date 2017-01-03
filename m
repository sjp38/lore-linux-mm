Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E49BB6B0038
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 13:22:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b1so1343767809pgc.5
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:22:50 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id n77si37838607pfj.225.2017.01.03.10.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 10:22:50 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id g1so34263138pgn.0
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:22:50 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 0/2] wake_up_page cleanups
Date: Wed,  4 Jan 2017 04:22:32 +1000
Message-Id: <20170103182234.30141-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-nfs@vger.kernel.org, linux-mm@kvack.org, NeilBrown <neilb@suse.de>, Trond Myklebust <trond.myklebust@primarydata.com>

I suggest getting acks for the nfs patch and merging these via
Andrew's tree.

Nicholas Piggin (2):
  nfs: no PG_private waiters remain, remove waker
  mm: un-export wake_up_page functions

 fs/nfs/write.c          |  2 --
 include/linux/pagemap.h | 12 ++----------
 mm/filemap.c            | 10 ++++++++--
 3 files changed, 10 insertions(+), 14 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
