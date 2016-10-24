Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE71F6B0260
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:26:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y138so34542639wme.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:26:15 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 5si12583639wmp.126.2016.10.24.08.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 08:26:14 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id f193so10317799wmg.3
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:26:14 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [Stable 4.4 - NEEDS REVIEW - 0/3] mm: working set fixes
Date: Mon, 24 Oct 2016 17:26:02 +0200
Message-Id: <20161024152605.11707-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Antonio SJ Musumeci <trapexit@spawn.link>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Miklos Szeredi <miklos@szeredi.hu>

Hi Johannes,
this is my attempt to backport your 22f2ac51b6d6 ("mm: workingset: fix
crash in shadow node shrinker caused by replace_page_cache_page()")
which has been marked for 3.15+ stable trees. There are 2 follow up
fixes for this patch d3798ae8c6f3 ("mm: filemap: don't plant shadow
entries without radix tree node") and 3ddf40e8c319 ("mm: filemap: fix
mapping->nrpages double accounting in fuse") which are backported here
as well.

This is not an area I would feel really strongly so I would highly
appreciate if you could review these backports. The first two needed
quite some tweaking.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
