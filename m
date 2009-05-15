Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F3CC76B0055
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:53:11 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090515145151.03a55298@binnacle.cx>
Date: Fri, 15 May 2009 14:53:27 -0400
From: starlight@binnacle.cx
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of
  process with hugepage shared memory segments attached
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Here's another possible clue:

I tried the first 'tcbm' testcase on a 2.6.27.7
kernel that was hanging around from a few months
ago and it breaks it 100% of the time.

Completely hoses huge memory.  Enough "bad pmd"
errors to fill the kernel log.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
