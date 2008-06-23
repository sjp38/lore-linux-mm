Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5NG460A021881
	for <linux-mm@kvack.org>; Mon, 23 Jun 2008 12:04:06 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5NG3tUe201366
	for <linux-mm@kvack.org>; Mon, 23 Jun 2008 12:03:55 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5NG3t96031229
	for <linux-mm@kvack.org>; Mon, 23 Jun 2008 12:03:55 -0400
Message-ID: <485FC974.70403@linux.vnet.ibm.com>
Date: Mon, 23 Jun 2008 11:04:04 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] hugetlb reservations -- MAP_PRIVATE fixes for split vmas
References: <485A8903.9030808@linux.vnet.ibm.com> <1213989474-5586-1-git-send-email-apw@shadowen.org>
In-Reply-To: <1213989474-5586-1-git-send-email-apw@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> As reported by Adam Litke and Jon Tollefson one of the libhugetlbfs
> regression tests triggers a negative overall reservation count.  When
> this occurs where there is no dynamic pool enabled tests will fail.
>
> Following this email are two patches to fix this issue:
>
> hugetlb reservations: move region tracking earlier -- simply moves the
>   region tracking code earlier so we do not have to supply prototypes, and
>
> hugetlb reservations: fix hugetlb MAP_PRIVATE reservations across vma
>   splits -- which moves us to tracking the consumed reservation so that
>   we can correctly calculate the remaining reservations at vma close time.
>
> This stack is against the top of v2.6.25-rc6-mm3, should this solution
> prove acceptable it would probabally need porting below Nicks multiple
> hugepage size patches and those updated; if so I would be happy to do
> that too.
>
> Jon could you have a test on this and see if it works out for you.
>
> -apw
>   
Looking good so far.
I am not seeing any of the tests push the reservation number negative -
with this patch set applied

Jon


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
