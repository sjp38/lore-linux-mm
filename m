Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CFA436B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 17:35:43 -0400 (EDT)
Message-ID: <4BEC704C.9000709@nortel.com>
Date: Thu, 13 May 2010 15:34:04 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: /proc/<pid>/maps question....why aren't adjacent memory chunks merged?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've got a system running a somewhat-modified 2.6.27 on 64-bit x86.

While investigating a userspace memory leak issue I noticed that
/proc/<pid>/maps showed a bunch of adjacent anonymous memory chunks with
identical permissions:

7fd048000000-7fd04c000000 rw-p 00000000 00:00 0
7fd04c000000-7fd050000000 rw-p 00000000 00:00 0
7fd050000000-7fd054000000 rw-p 00000000 00:00 0
7fd054000000-7fd058000000 rw-p 00000000 00:00 0
7fd058000000-7fd05c000000 rw-p 00000000 00:00 0
7fd05c000000-7fd060000000 rw-p 00000000 00:00 0
7fd060000000-7fd064000000 rw-p 00000000 00:00 0
7fd064000000-7fd068000000 rw-p 00000000 00:00 0
7fd068000000-7fd06c000000 rw-p 00000000 00:00 0
7fd06c000000-7fd070000000 rw-p 00000000 00:00 0
7fd070000000-7fd074000000 rw-p 00000000 00:00 0
7fd074000000-7fd078000000 rw-p 00000000 00:00 0
7fd078000000-7fd07c000000 rw-p 00000000 00:00 0
7fd07c000000-7fd07fffe000 rw-p 00000000 00:00 0

I was under the impression that the kernel would merge areas together in
this circumstance.  Does anyone have an idea about what's going on here?

Thanks,

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
