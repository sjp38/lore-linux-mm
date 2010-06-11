Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAFE6B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:32:46 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o5B5WXg5012819
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:32:33 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5B5WbgM1802434
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:32:37 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5B5Wbax016017
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:32:37 +1000
Message-ID: <4C11CA71.9010606@in.ibm.com>
Date: Fri, 11 Jun 2010 11:02:33 +0530
From: Sachin Sant <sachinp@in.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.6.35-rc2: GPF while executing libhugetlbfs tests on x86_64
References: <4C0BC7F0.8030109@in.ibm.com> <20100608091817.GA27717@csn.ul.ie> <4C0E2E84.6060605@in.ibm.com> <20100608123622.GE27717@csn.ul.ie>
In-Reply-To: <20100608123622.GE27717@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> If the problem has gone away since 2.6.35-rc2, the most likely candidate fix
> patch is commit [386f40: Revert "tty: fix a little bug in scrup, vt.c"] which
> reverts the patch you previously identified as being a problem.  The commit
> message also matches roughly what you are seeing with the 0x0720 patterns.
>
> Can you retest with 2.6.35-rc2 with commit 386f40 applied and see if it
> also fixes up your problem please?
>   
I could not recreate this problem against 2.6.35-rc2 + commit 386f40.

Thanks
-Sachin

-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
