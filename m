Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 33ADF6B0044
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 17:42:15 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/3 v1] HWPOISON: improve dirty pagecache error handling
Date: Fri, 10 Aug 2012 17:41:50 -0400
Message-Id: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Naoya Horiguchi <nhoriguc@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

This patchset is to improve handling and reporting of memory errors on
dirty pagecache.

Patch 1 is to fix a messaging bug, and patch 2 is to temporarily undo
the code which can happen the data lost.  I think these two are obvious
fixes so I want to push them to merge promptly.

Patch 3 is for a new feature. The problem in error reporting (where AS_EIO
we rely on to report the error to userspace is cleared once checked) is
discussed when hwpoison core patches were reviewed, and we left it unfixed
because it can be fixed with more generic solution which covers legacy EIO.
But in my opinion, legacy EIO and hwpoison are different in how it can or
should be handled (for example, as described in patch 3, we can recover
from memory errors on dirty pagecache with overwriting.) So this patch
only solves the problem of memory error reporting.

My test for this patchset is available on:
https://github.com/Naoya-Horiguchi/test_memory_error_on_dirty_pagecache.git

Could you review or comment?

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
