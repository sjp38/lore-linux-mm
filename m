Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7SMffbi020616
	for <linux-mm@kvack.org>; Tue, 28 Aug 2007 18:41:41 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7SMffAS432674
	for <linux-mm@kvack.org>; Tue, 28 Aug 2007 16:41:41 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7SMffgl025405
	for <linux-mm@kvack.org>; Tue, 28 Aug 2007 16:41:41 -0600
Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1
	Kernel panic - not syncing: DMA: Memory would be corrupted)
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
	 <20070823142133.9359a1ce.akpm@linux-foundation.org>
	 <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 28 Aug 2007 17:41:40 -0500
Message-Id: <1188340900.15336.84.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-08-24 at 15:53 +0900, Yasunori Goto wrote:
> I found find_next_best_node() was wrong.
> I confirmed boot up by the following patch.
> Mel-san, Kamalesh-san, could you try this?

FYI: This patch also allows the alloc-instantiate-race testcase in
libhugetlbfs to pass again :)

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
