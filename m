Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m77BZuwN203646
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 11:35:56 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m77BZt894481212
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 12:35:55 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m77BZtF9017434
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 12:35:55 +0100
Subject: Re: [PATCH 1/1] allocate structures for reservation tracking in
	hugetlbfs outside of spinlocks
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <1218049425-19416-1-git-send-email-apw@shadowen.org>
References: <1218033802.7764.31.camel@ubuntu>
	 <1218049425-19416-1-git-send-email-apw@shadowen.org>
Content-Type: text/plain
Date: Thu, 07 Aug 2008 13:35:54 +0200
Message-Id: <1218108954.4662.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-08-06 at 20:03 +0100, Andy Whitcroft wrote:
> [Gerald, could you see if this works for you it seems to for us on
> an x86 build.  If it does we can push it up to Andrew.]

Yes, it works fine with your patch.

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
