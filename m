Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0BIxPpC012025
	for <linux-mm@kvack.org>; Fri, 11 Jan 2008 13:59:25 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BIxPLZ083106
	for <linux-mm@kvack.org>; Fri, 11 Jan 2008 11:59:25 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BIxO1c021989
	for <linux-mm@kvack.org>; Fri, 11 Jan 2008 11:59:24 -0700
Subject: Re: [patch] fix hugetlbfs quota leak
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <b040c32a0801102224o54da2bfbk4a62b0cfe1d35f37@mail.gmail.com>
References: <b040c32a0801102224o54da2bfbk4a62b0cfe1d35f37@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 11 Jan 2008 13:03:09 -0600
Message-Id: <1200078189.3296.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-01-10 at 22:24 -0800, Ken Chen wrote:
> In the error path of both shared and private hugetlb page allocation,
> the file system quota is never undone, leading to fs quota leak.
> Patch to fix them up.
> 
> Signed-off-by: Ken Chen <kenchen@google.com>

Thanks Ken.

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
