Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEAB6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 02:29:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id c14so205856984pgn.11
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 23:29:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 4si4825232pla.710.2017.07.25.23.29.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 23:29:02 -0700 (PDT)
Message-Id: <201707260628.v6Q6SmaS030814@www262.sakura.ne.jp>
Subject: [4.13-rc1] /proc/meminfo reports that Slab: is little used.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 26 Jul 2017 15:28:48 +0900
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

Commit 385386cff4c6f047 ("mm: vmstat: move slab statistics from zone to
node counters") broke "Slab:" field of /proc/meminfo . It shows nearly 0kB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
