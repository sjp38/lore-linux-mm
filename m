Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4532D6B008C
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 14:05:52 -0400 (EDT)
Message-ID: <4CC869F5.2070405@redhat.com>
Date: Wed, 27 Oct 2010 14:05:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
References: <1288200090-23554-1-git-send-email-yinghan@google.com>
In-Reply-To: <1288200090-23554-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 10/27/2010 01:21 PM, Ying Han wrote:
> kswapd's use case of hardware PTE accessed bit is to approximate page LRU.  The
> ActiveLRU demotion to InactiveLRU are not base on accessed bit, while it is only
> used to promote when a page is on inactive LRU list.  All of the state transitions
> are triggered by memory pressure and thus has weak relationship with respect to
> time.  In addition, hardware already transparently flush tlb whenever CPU context
> switch processes and given limited hardware TLB resource, the time period in
> which a page is accessed but not yet propagated to struct page is very small
> in practice. With the nature of approximation, kernel really don't need to flush TLB
> for changing PTE's access bit.  This commit removes the flush operation from it.
>
> Signed-off-by: Ying Han<yinghan@google.com>
> Singed-off-by: Ken Chen<kenchen@google.com>

The reasoning behind the patch makes sense.

However, have you measured any improvements in run time with
this patch?  The VM is already tweaked to minimize the number
of pages that get aged, so it would be interesting to know
where you saw issues.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
