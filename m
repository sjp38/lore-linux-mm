Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB966B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 19:42:50 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so31556359wiv.2
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 16:42:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt3si38622271wid.19.2014.12.02.16.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 16:42:49 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Improve documentation of FADV_DONTNEED behaviour
Date: Wed,  3 Dec 2014 00:42:45 +0000
Message-Id: <1417567367-9298-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Partial page discard requests are ignored and the documentation on why this
is correct behaviour sucks. A readahead patch looked like a "regression" to
a random IO storage benchmark because posix_fadvise() was used incorrectly
to force IO requests to go to disk. In reality, the benchmark sucked but
it was non-obvious why. Patch 1 updates the kernel comment in case someone
"fixes" either readahead or fadvise for inappropriate reasons. Patch 2
updates the relevant man page on the rough off chance that application
developers do not read kernel source comments.

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
