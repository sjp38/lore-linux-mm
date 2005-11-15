Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAFM0Wcq016710
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 17:00:32 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAFM0W4F121500
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 17:00:32 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAFM0Vm0007339
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 17:00:31 -0500
Subject: Re: [PATCH] Add NUMA policy support for huge pages.
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0511151342310.10995@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511151342310.10995@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 15 Nov 2005 15:59:26 -0600
Message-Id: <1132091966.22243.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-15 at 13:44 -0800, Christoph Lameter wrote:
> The huge_zonelist() function in the memory policy layer
> provides an list of zones ordered by NUMA distance. The hugetlb
> layer will walk that list looking for a zone that has available huge pages
> but is also in the nodeset of the current cpuset.
> 
> This patch does not contain the folding of find_or_alloc_huge_page() that
> was controversial in the earlier discussion.

Yep, I still agree with this part.

> Signed-off-by: Christoph Lameter <clameter@sgi.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
