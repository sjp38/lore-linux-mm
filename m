Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 107656B0098
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:02:42 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] kernel BUG at mm/huge_memory.c:212!
Date: Fri, 30 Nov 2012 17:03:39 +0200
Message-Id: <1354287821-5925-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <50B52E17.8020205@suse.cz>
References: <50B52E17.8020205@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Jiri,

Sorry for late answer. It took time to reproduce and debug the issue.

Could you test two patches below by thread. I expect it to fix both
issues: put_huge_zero_page() and Bad rss-counter state.

Kirill A. Shutemov (2):
  thp: fix anononymous page accounting in fallback path for COW of HZP
  thp: avoid race on multiple parallel page faults to the same page

 mm/huge_memory.c | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
