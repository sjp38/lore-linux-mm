Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 67DFB6B005A
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 10:50:01 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2114A82C510
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 11:07:43 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DD-MYKh-4VEu for <linux-mm@kvack.org>;
	Tue, 16 Jun 2009 11:07:43 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7B19482C5AF
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 11:07:33 -0400 (EDT)
Date: Tue, 16 Jun 2009 10:51:05 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring
 behaviour more in line with expectations V3
In-Reply-To: <20090616134423.GD14241@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0906161049180.26093@gentwo.org>
References: <20090615163018.B43A.A69D9226@jp.fujitsu.com> <20090615105651.GD23198@csn.ul.ie> <20090616202157.99AF.A69D9226@jp.fujitsu.com> <20090616134423.GD14241@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jun 2009, Mel Gorman wrote:

> I don't have a particular workload in mind to be perfectly honest. I'm just not
> convinced of the wisdom of trying to unmap pages by default in zone_reclaim()
> just because the NUMA distances happen to be large.

zone reclaim = 1 is supposed to be light weight with minimal impact. The
intend was just to remove potentially unused pagecache pages so that node
local allocations can succeed again. So lets not unmap pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
