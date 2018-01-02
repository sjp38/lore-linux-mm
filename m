Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3CB56B028E
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 21:09:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f7so34341069pfa.21
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 18:09:27 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k15si24432607pgf.34.2018.01.01.18.09.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Jan 2018 18:09:26 -0800 (PST)
Subject: Is GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC) & ~__GFP_DIRECT_RECLAIM supported?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201801021108.BCC17635.FQtOHMOLJSVFFO@I-love.SAKURA.ne.jp>
Date: Tue, 2 Jan 2018 11:08:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, wei.w.wang@intel.com, willy@infradead.org, mst@redhat.com

virtio-balloon wants to try allocation only when that allocation does not cause
OOM situation. Since there is no gfp flag which succeeds allocations only if
there is plenty of free memory (i.e. higher watermark than other requests),
virtio-balloon needs to watch for OOM notifier and release just allocated memory
when OOM notifier is invoked.

Currently virtio-balloon is using

  GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY

for allocation, but is

  GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC) & ~__GFP_DIRECT_RECLAIM

supported (from MM subsystem's point of view) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
