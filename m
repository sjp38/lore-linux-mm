Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id l8E5fwJH013805
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 06:41:58 +0100
Received: from nf-out-0910.google.com (nfcd3.prod.google.com [10.48.105.3])
	by zps37.corp.google.com with ESMTP id l8E5fuR5008308
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 22:41:57 -0700
Received: by nf-out-0910.google.com with SMTP id d3so554337nfc
        for <linux-mm@kvack.org>; Thu, 13 Sep 2007 22:41:56 -0700 (PDT)
Message-ID: <b040c32a0709132241t7d464a2x68d1194887cd8e93@mail.gmail.com>
Date: Thu, 13 Sep 2007 22:41:54 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH 1/5] hugetlb: Account for hugepages as locked_vm
In-Reply-To: <20070913175905.27074.92434.stgit@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070913175855.27074.27030.stgit@kernel>
	 <20070913175905.27074.92434.stgit@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

On 9/13/07, Adam Litke <agl@us.ibm.com> wrote:
> Hugepages allocated to a process are pinned into memory and are not
> reclaimable.  Currently they do not contribute towards the process' locked
> memory.  This patch includes those pages in the process' 'locked_vm' pages.

On x86_64, hugetlb can share page table entry if multiple processes
have their virtual addresses all lined up perfectly.  Because of that,
mm->locked_vm can go negative with this patch depending on the order
of which process fault in hugetlb pages and which one unmaps it last.

Have you checked all user of mm->locked_vm that a negative number
won't trigger unpleasant result?

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
