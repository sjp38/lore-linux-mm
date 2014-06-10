Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8B76B0102
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 12:37:58 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id x13so4847658wgg.3
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 09:37:57 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id m2si17659683wiz.34.2014.06.10.09.37.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 09:37:56 -0700 (PDT)
From: Kamal Mostafa <kamal@canonical.com>
Subject: [3.13.y.z extended stable] Patch "mm/numa: Remove BUG_ON() in __handle_mm_fault()" has been added to staging queue
Date: Tue, 10 Jun 2014 09:37:40 -0700
Message-Id: <1402418260-8200-1-git-send-email-kamal@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sunil Pandey <sunil.k.pandey@intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, lwoodman@redhat.com, dave.hansen@intel.com, Ingo Molnar <mingo@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Kamal Mostafa <kamal@canonical.com>, kernel-team@lists.ubuntu.com

This is a note to let you know that I have just added a patch titled

    mm/numa: Remove BUG_ON() in __handle_mm_fault()

to the linux-3.13.y-queue branch of the 3.13.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.13.y-queue

This patch is scheduled to be released in version 3.13.11.3.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.13.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Kamal

------
