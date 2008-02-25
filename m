Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PMV3Tx030724
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:31:03 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PMV3be254498
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:31:03 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PMV3ee029543
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:31:03 -0500
Subject: Re: [PATCH 3/3] hugetlb: Decrease hugetlb_lock cycling in
	gather_surplus_huge_pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20080225220152.23627.25591.stgit@kernel>
References: <20080225220119.23627.33676.stgit@kernel>
	 <20080225220152.23627.25591.stgit@kernel>
Content-Type: text/plain
Date: Mon, 25 Feb 2008 14:31:00 -0800
Message-Id: <1203978660.11846.11.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-25 at 14:01 -0800, Adam Litke wrote:
> +       /* Free unnecessary surplus pages to the buddy allocator */
> +       if (!list_empty(&surplus_list)) {
> +               spin_unlock(&hugetlb_lock);
> +               list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> +                       list_del(&page->lru);

What is the surplus_list protected by?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
