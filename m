Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k41FlSwd026584
	for <linux-mm@kvack.org>; Mon, 1 May 2006 11:47:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k41FlPCY217598
	for <linux-mm@kvack.org>; Mon, 1 May 2006 11:47:28 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k41FlPQt012222
	for <linux-mm@kvack.org>; Mon, 1 May 2006 11:47:25 -0400
Subject: RE: [RFC] Hugetlb fallback to normal pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4sur0l$s7b0u@fmsmga001.fm.intel.com>
References: <4sur0l$s7b0u@fmsmga001.fm.intel.com>
Content-Type: text/plain
Date: Mon, 01 May 2006 08:46:47 -0700
Message-Id: <1146498407.32079.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Adam Litke' <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-04-27 at 16:31 -0700, Chen, Kenneth W wrote:
> Some arch don't support mixed page size within a range of virtual address.
> So automatic fallback to smaller page won't work on that arch :-( 

Well, they're mixed to _some_ degree :)

On ppc64, for instance, we have to do the selection in 256MB granules.
It is still feasible, the cost is just much higher than it would be on
x86.

What are the restrictions on ia64?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
