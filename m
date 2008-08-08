Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m78CvvJY688000
	for <linux-mm@kvack.org>; Fri, 8 Aug 2008 12:57:57 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m78Cvu183977292
	for <linux-mm@kvack.org>; Fri, 8 Aug 2008 14:57:56 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m78Cvu8p002328
	for <linux-mm@kvack.org>; Fri, 8 Aug 2008 14:57:56 +0200
Subject: Re: [PATCH 1/1] allocate structures for reservation tracking in
	hugetlbfs outside of spinlocks v2
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <1218193855-25832-1-git-send-email-apw@shadowen.org>
References: <20080807143824.8e0803da.akpm@linux-foundation.org>
	 <1218193855-25832-1-git-send-email-apw@shadowen.org>
Content-Type: text/plain
Date: Fri, 08 Aug 2008 14:57:55 +0200
Message-Id: <1218200276.10315.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-08-08 at 12:10 +0100, Andy Whitcroft wrote:
> [Bah, while reviewing the locking based on your previous email I spotted
> that we need to check the return from the vma_needs_reservation call for
> allocation errors.  Here is an updated patch to correct this.  This passes
> testing here.  Gerald could you test thing one too.]

Ok, it works here too.

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
