Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 338C46B0092
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:35:55 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A76F582CFCE
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:49:12 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5hR9-Hgg3uxt for <linux-mm@kvack.org>;
	Mon, 23 Mar 2009 09:49:06 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 23C7082CECC
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:48:56 -0400 (EDT)
Date: Mon, 23 Mar 2009 09:38:38 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] fix vmscan to take care of nodemask
In-Reply-To: <20090323114814.GB6484@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903230936130.4095@qirst.com>
References: <20090323100356.e980d266.kamezawa.hiroyu@jp.fujitsu.com> <20090323114814.GB6484@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, riel@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009, Mel Gorman wrote:

> try_to_free_pages() is used for the direct reclaim of up to
> SWAP_CLUSTER_MAX pages when watermarks are low. The caller to
> alloc_pages_nodemask() can specify a nodemask of nodes that are allowed
> to be used but this is not passed to try_to_free_pages(). This can lead
> to the unnecessary reclaim of pages that are unusable by the caller and
> in the worst case lead to allocation failure as progress was not been
> made where it is needed.
>
> This patch passes the nodemask used for alloc_pages_nodemask() to
> try_to_free_pages().


This is only useful for MPOL_BIND. Direct reclaim within a cpuset already
honors the boundaries of the cpuset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
