Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m74L44v5010345
	for <linux-mm@kvack.org>; Mon, 4 Aug 2008 17:04:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m74LAGwB112824
	for <linux-mm@kvack.org>; Mon, 4 Aug 2008 15:10:16 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m74LAGhi013933
	for <linux-mm@kvack.org>; Mon, 4 Aug 2008 15:10:16 -0600
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080731103137.GD1704@csn.ul.ie>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
	 <20080730014308.2a447e71.akpm@linux-foundation.org>
	 <20080730172317.GA14138@csn.ul.ie>
	 <20080730103407.b110afc2.akpm@linux-foundation.org>
	 <20080730193010.GB14138@csn.ul.ie>
	 <20080730130709.eb541475.akpm@linux-foundation.org>
	 <20080731103137.GD1704@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 04 Aug 2008 14:10:11 -0700
Message-Id: <1217884211.20260.144.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-31 at 11:31 +0100, Mel Gorman wrote:
> We are a lot more reliable than we were although exact quantification is
> difficult because it's workload dependent. For a long time, I've been able
> to test bits and pieces with hugepages by allocating the pool at the time
> I needed it even after days of uptime. Previously this required a reboot.

This is also a pretty big expansion of fs/hugetlb/ use outside of the
filesystem itself.  It is hacking the existing shared memory
kernel-internal user to spit out effectively anonymous memory.

Where do we draw the line where we stop using the filesystem for this?
Other than the immediate code reuse, does it gain us anything?

I have to think that actually refactoring the filesystem code and making
it usable for really anonymous memory, then using *that* in these
patches would be a lot more sane.  Especially for someone that goes to
look at it in a year. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
