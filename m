Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5DE3dig018773
	for <linux-mm@kvack.org>; Fri, 13 Jun 2008 10:03:39 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5DE3VAJ178430
	for <linux-mm@kvack.org>; Fri, 13 Jun 2008 08:03:32 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5DE3Uol003702
	for <linux-mm@kvack.org>; Fri, 13 Jun 2008 08:03:30 -0600
Subject: Re: [RFC PATCH 0/2] Merge HUGETLB_PAGE and HUGETLBFS Kconfig
	options
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080613134629.GD16344@linux-mips.org>
References: <1213296540.17108.8.camel@localhost.localdomain>
	 <20080613134629.GD16344@linux-mips.org>
Content-Type: text/plain
Date: Fri, 13 Jun 2008 10:03:28 -0400
Message-Id: <1213365808.15016.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mm <linux-mm@kvack.org>, npiggin@suse.de, nacc@us.ibm.com, mel@csn.ul.ie, Eric B Munson <ebmunson@us.ibm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-13 at 14:46 +0100, Ralf Baechle wrote:
> MIPS doesn't do HUGETLB (at least not in-tree atm) so I'm not sure why
> linux-mips@linux-mips.org was cc'ed at all.  So feel free to add my
> Couldnt-care-less: ack line ;-)

Sorry :)  My patches touched your defconfigs so I felt it prudent to
include the mips list as an FYI.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
