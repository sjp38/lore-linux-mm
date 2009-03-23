Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5024B6B003D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:23:31 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 9so1032910qwj.44
        for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:31:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0903230936130.4095@qirst.com>
References: <20090323100356.e980d266.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090323114814.GB6484@csn.ul.ie>
	 <alpine.DEB.1.10.0903230936130.4095@qirst.com>
Date: Tue, 24 Mar 2009 00:31:05 +0900
Message-ID: <2f11576a0903230831r72892eadoabfc0f128e9f55a6@mail.gmail.com>
Subject: Re: [PATCH] fix vmscan to take care of nodemask
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, riel@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2009/3/23 Christoph Lameter <cl@linux-foundation.org>:
> On Mon, 23 Mar 2009, Mel Gorman wrote:
>
>> try_to_free_pages() is used for the direct reclaim of up to
>> SWAP_CLUSTER_MAX pages when watermarks are low. The caller to
>> alloc_pages_nodemask() can specify a nodemask of nodes that are allowed
>> to be used but this is not passed to try_to_free_pages(). This can lead
>> to the unnecessary reclaim of pages that are unusable by the caller and
>> in the worst case lead to allocation failure as progress was not been
>> made where it is needed.
>>
>> This patch passes the nodemask used for alloc_pages_nodemask() to
>> try_to_free_pages().
>
> This is only useful for MPOL_BIND. Direct reclaim within a cpuset already
> honors the boundaries of the cpuset.

Do you mean nak or comment adding request?
I agree you. but I don't find any weak point of this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
