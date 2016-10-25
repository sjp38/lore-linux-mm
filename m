Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFDA96B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 03:52:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t25so136698349pfg.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:52:06 -0700 (PDT)
Received: from mail-pf0-f194.google.com (mail-pf0-f194.google.com. [209.85.192.194])
        by mx.google.com with ESMTPS id h7si9601571pgf.209.2016.10.25.00.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 00:52:05 -0700 (PDT)
Received: by mail-pf0-f194.google.com with SMTP id i85so18856998pfa.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:52:05 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable 4.4 0/4] mm: workingset backports
Date: Tue, 25 Oct 2016 09:51:44 +0200
Message-Id: <20161025075148.31661-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Antonio SJ Musumeci <trapexit@spawn.link>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Miklos Szeredi <miklos@szeredi.hu>

Hi,
here is the backport of (hopefully) all workingset related fixes for
4.4 kernel. The series has been reviewed by Johannes [1]. The main
motivation for the backport is 22f2ac51b6d6 ("mm: workingset: fix crash
in shadow node shrinker caused by replace_page_cache_page()") which is
a fix for a triggered BUG_ON. This is not sufficient because there are
follow up fixes which were introduced later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
