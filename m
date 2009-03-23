Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 544ED6B003D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:35:13 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F20D882D010
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 11:50:23 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 89hLov-2uokr for <linux-mm@kvack.org>;
	Mon, 23 Mar 2009 11:50:23 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2CEB782D019
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 11:50:09 -0400 (EDT)
Date: Mon, 23 Mar 2009 11:39:17 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] fix vmscan to take care of nodemask
In-Reply-To: <2f11576a0903230831r72892eadoabfc0f128e9f55a6@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0903231137010.11796@qirst.com>
References: <20090323100356.e980d266.kamezawa.hiroyu@jp.fujitsu.com>  <20090323114814.GB6484@csn.ul.ie>  <alpine.DEB.1.10.0903230936130.4095@qirst.com> <2f11576a0903230831r72892eadoabfc0f128e9f55a6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, riel@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Mar 2009, KOSAKI Motohiro wrote:

> 2009/3/23 Christoph Lameter <cl@linux-foundation.org>:
> > On Mon, 23 Mar 2009, Mel Gorman wrote:
> >
> >> try_to_free_pages() is used for the direct reclaim of up to
> >> SWAP_CLUSTER_MAX pages when watermarks are low. The caller to
> >> alloc_pages_nodemask() can specify a nodemask of nodes that are allowed
> >> to be used but this is not passed to try_to_free_pages(). This can lead
> >> to the unnecessary reclaim of pages that are unusable by the caller and
> >> in the worst case lead to allocation failure as progress was not been
> >> made where it is needed.
> >>
> >> This patch passes the nodemask used for alloc_pages_nodemask() to
> >> try_to_free_pages().
> >
> > This is only useful for MPOL_BIND. Direct reclaim within a cpuset already
> > honors the boundaries of the cpuset.
>
> Do you mean nak or comment adding request?
> I agree you. but I don't find any weak point of this patch.

Just a comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
