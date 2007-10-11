Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9BMA6wf000926
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 18:10:06 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9BMA6G7075490
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 18:10:06 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9BM9u7F008952
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 18:09:56 -0400
Subject: Re: [Libhugetlbfs-devel] [PATCH 2/4] hugetlb: Try to grow hugetlb
	pool for MAP_PRIVATE mappings
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071001151758.12825.26569.stgit@kernel>
References: <20071001151736.12825.75984.stgit@kernel>
	 <20071001151758.12825.26569.stgit@kernel>
Content-Type: text/plain
Date: Thu, 11 Oct 2007 15:09:43 -0700
Message-Id: <1192140583.20859.40.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, libhugetlbfs-devel@lists.sourceforge.net, Dave McCracken <dave.mccracken@oracle.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Bill Irwin <bill.irwin@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-01 at 08:17 -0700, Adam Litke wrote:
> 
>         spin_lock(&hugetlb_lock);
> -       enqueue_huge_page(page);
> +       if (surplus_huge_pages_node[nid]) {
> +               update_and_free_page(page);
> +               surplus_huge_pages--;
> +               surplus_huge_pages_node[nid]--;
> +       } else {
> +               enqueue_huge_page(page);
> +       }
>         spin_unlock(&hugetlb_lock);
>  } 

Why does it matter that these surplus pages are tracked per-node?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
