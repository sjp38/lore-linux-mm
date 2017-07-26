Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 166CB6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:55:43 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v11so6886297oif.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:55:43 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y2si4606887oiy.62.2017.07.26.10.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 10:55:42 -0700 (PDT)
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/4] mm/gfs2: extend file_* API, and convert gfs2 to errseq_t error reporting
Date: Wed, 26 Jul 2017 13:55:34 -0400
Message-Id: <20170726175538.13885-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

From: Jeff Layton <jlayton@redhat.com>

I sent a small patch earlier this week to make sync_file_range use
errseq_t reporting.

This set respins that patch into a patch that adds a bit more file_*
infrastructure, and then patches to make sync_file_range and fsync
on gfs2 report writeback errors properly.

There's also a small cleanup patch for mm/filemap.c to consolidate
the DAX handling checks in the existing infrastructure.

Jeff Layton (4):
  mm: consolidate dax / non-dax checks for writeback
  mm: add file_fdatawait_range and file_write_and_wait
  fs: convert sync_file_range to use errseq_t based error-tracking
  gfs2: convert to errseq_t based writeback error reporting for fsync

 fs/gfs2/file.c     |  6 +++--
 fs/sync.c          |  4 +--
 include/linux/fs.h |  7 +++++-
 mm/filemap.c       | 71 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 77 insertions(+), 11 deletions(-)

-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
