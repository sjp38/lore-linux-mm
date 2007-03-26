Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2QEH7n4031703
	for <linux-mm@kvack.org>; Mon, 26 Mar 2007 10:17:07 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2QEH7Fi052308
	for <linux-mm@kvack.org>; Mon, 26 Mar 2007 08:17:07 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2QEH6Fn010139
	for <linux-mm@kvack.org>; Mon, 26 Mar 2007 08:17:07 -0600
Subject: Re: [patch 1/2] hugetlb: add resv argument to hugetlb_file_setup
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <b040c32a0703231542r77030723o214255a5fa591dec@mail.gmail.com>
References: <b040c32a0703231542r77030723o214255a5fa591dec@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 26 Mar 2007 09:17:04 -0500
Message-Id: <1174918625.21684.78.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-03-23 at 15:42 -0700, Ken Chen wrote:
> rename hugetlb_zero_setup() to hugetlb_file_setup() to better match
> function name convention like shmem implementation.  Also add an
> argument to the function to indicate whether file setup should reserve
> hugetlb page upfront or not.
> 
> Signed-off-by: Ken Chen <kenchen@google.com>

This patch doesn't really look bad at all, but...

I am worried that what might seem nice and clean right now will slowly
get worse.  This implements an interface on top of another interface
(char device on top of a filesystem).  What is the next hugetlbfs
function that will need a boolean switch to handle a character device
special case?

Am I just worrying too much here?  Although my pagetable_operations
patches aren't the most popular right now, they do have at least one
advantage IMO: they enable side-by-side implementation of the interfaces
as opposed to stacking them.  Keeping them separate removes the need for
if ((vm_flags & VM_HUGETLB) && (is_hugetlbfs_chardev())) checking. 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
