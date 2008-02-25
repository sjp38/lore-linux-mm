Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PMi3EU017383
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:44:03 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PMiQbV177384
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 15:44:26 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PMiQU3022864
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 15:44:26 -0700
Subject: Re: [PATCH 3/3] hugetlb: Decrease hugetlb_lock cycling in
	gather_surplus_huge_pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1203978660.11846.11.camel@nimitz.home.sr71.net>
References: <20080225220119.23627.33676.stgit@kernel>
	 <20080225220152.23627.25591.stgit@kernel>
	 <1203978660.11846.11.camel@nimitz.home.sr71.net>
Content-Type: text/plain
Date: Mon, 25 Feb 2008 16:51:45 -0600
Message-Id: <1203979905.3837.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-25 at 14:31 -0800, Dave Hansen wrote:
> On Mon, 2008-02-25 at 14:01 -0800, Adam Litke wrote:
> > +       /* Free unnecessary surplus pages to the buddy allocator */
> > +       if (!list_empty(&surplus_list)) {
> > +               spin_unlock(&hugetlb_lock);
> > +               list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> > +                       list_del(&page->lru);
> 
> What is the surplus_list protected by?

It's a local variable on the stack.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
