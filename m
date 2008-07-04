Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m641mnWG029582
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 11:48:49 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m641nG7J4120830
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 11:49:16 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m641nfX7030779
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 11:49:41 +1000
Message-ID: <486D81B9.9030704@linux.vnet.ibm.com>
Date: Fri, 04 Jul 2008 07:19:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.26-rc8-mm1] memrlimit: fix mmap_sem deadlock
References: <Pine.LNX.4.64.0807032143110.10641@blonde.site> <20080703160117.b3781463.akpm@linux-foundation.org>
In-Reply-To: <20080703160117.b3781463.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> There doesn't seem to have been much discussion regarding your recent
> objections to the memrlimit patches.  But it caused me to put a big
> black mark on them.  Perhaps sending it all again would be helpful.

Black marks are not good, but there have been some silly issues found with them.
I have been addressing/answering concerns raised so far. Would you like me to
fold all patches and fixes and send them out for review again?


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
