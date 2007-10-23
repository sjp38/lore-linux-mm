Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9NEqp45019334
	for <linux-mm@kvack.org>; Tue, 23 Oct 2007 10:52:51 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9NEqemH113318
	for <linux-mm@kvack.org>; Tue, 23 Oct 2007 08:52:42 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9NEqcJa016537
	for <linux-mm@kvack.org>; Tue, 23 Oct 2007 08:52:39 -0600
Subject: Re: [patch] hugetlb: fix i_blocks accounting
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <b040c32a0710201118g5abb6608me57d7b9057f86919@mail.gmail.com>
References: <b040c32a0710201118g5abb6608me57d7b9057f86919@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 23 Oct 2007 09:52:34 -0500
Message-Id: <1193151154.18417.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2007-10-20 at 11:18 -0700, Ken Chen wrote:
> For administrative purpose, we want to query actual block usage for
> hugetlbfs file via fstat.  Currently, hugetlbfs always return 0.  Fix
> that up since kernel already has all the information to track it
> properly.

Hey Ken.  You might want to wait on this for another minute or two.  I
will be sending out patches later today to fix up hugetlbfs quotas.
Right now the code does not handle private mappings correctly (ie.  it
does not call get_quota() for COW pages and it never calls put_quota()
for any private page).  Because of this, your i_blocks number will be
wrong most of the time.


-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
