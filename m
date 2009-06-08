Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A41766B004D
	for <linux-mm@kvack.org>; Sun,  7 Jun 2009 20:36:22 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090606235223.05a10068@binnacle.cx>
Date: Sun, 07 Jun 2009 21:25:06 -0400
From: starlight@binnacle.cx
Subject: Re: [PATCH 0/2] Fixes for hugetlbfs-related problems on
  shared memory
In-Reply-To: <1243422749-6256-1-git-send-email-mel@csn.ul.ie>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Eric B Munson <ebmunson@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, wli@movementarian.org
List-ID: <linux-mm.kvack.org>

Mel,

Tried out the two new patches on 2.6.26.4 and everything is 
working now.  The application that uncovered the issue works 
perfectly and hugepages function sanely.

Thank you for the fix.

Regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
