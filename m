Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1JIYtRR003923
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 13:34:55 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1JIZ4VD189576
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 11:35:04 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1JIZ4vX008395
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 11:35:04 -0700
Subject: Re: [PATCH] hugetlb: ensure we do not reference a surplus page
	after handing it to buddy
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1203445688.0@pinky>
References: <1203445688.0@pinky>
Content-Type: text/plain
Date: Tue, 19 Feb 2008 12:41:51 -0600
Message-Id: <1203446512.11987.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, Nishanth Aravamudan <nacc@us.ibm.com>, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Indeed.  I'll take credit for this thinko...

On Tue, 2008-02-19 at 18:28 +0000, Andy Whitcroft wrote:
> When we free a page via free_huge_page and we detect that we are in
> surplus the page will be returned to the buddy.  After this we no longer
> own the page.  However at the end free_huge_page we clear out our mapping
> pointer from page private.  Even where the page is not a surplus we
> free the page to the hugepage pool, drop the pool locks and then clear
> page private.  In either case the page may have been reallocated.  BAD.
> 
> Make sure we clear out page private before we free the page.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
