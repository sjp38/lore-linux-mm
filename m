Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 905796B006E
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 11:18:35 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so17692356wgg.38
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:18:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cx1si2041162wjb.99.2014.12.16.08.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 08:18:34 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/3 resend] mm: close race between dirtying and truncation
Date: Tue, 16 Dec 2014 11:18:08 -0500
Message-Id: <1418746691-326-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew,

it looks like these 3 patches fell on the floor.  The first one is a
bug fix that closes a race condition between truncation and dirtying
from do_wp_page(), which can result in a dirty-accounting error.  #2
and #3 simplify the code in the area.  Please consider them for 3.19.

Thanks!

 include/linux/writeback.h |  1 -
 mm/memory.c               | 54 ++++++++++++++++++---------------------------
 mm/page-writeback.c       | 43 ++++++++++--------------------------
 3 files changed, 34 insertions(+), 64 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
