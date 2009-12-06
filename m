Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1694B60021B
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 16:01:50 -0500 (EST)
Message-ID: <4B1C1BB8.9080301@redhat.com>
Date: Sun, 06 Dec 2009 16:01:44 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] wipe_page_reference return SWAP_AGAIN if VM pressulre
 is low and lock contention is detected.
References: <20091204173233.5891.A69D9226@jp.fujitsu.com> <20091204174439.58A3.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091204174439.58A3.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/04/2009 03:45 AM, KOSAKI Motohiro wrote:
>  From 3fb2a585729a37e205c5ea42ac6c48d4a6c0a29c Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 4 Dec 2009 12:54:37 +0900
> Subject: [PATCH 6/7] wipe_page_reference return SWAP_AGAIN if VM pressulre is low and lock contention is detected.
>
> Larry Woodman reported AIM7 makes serious ptelock and anon_vma_lock
> contention on current VM. because SplitLRU VM (since 2.6.28) remove
> calc_reclaim_mapped() test, then shrink_active_list() always call
> page_referenced() against mapped page although VM pressure is low.
> Lightweight VM pressure is very common situation and it easily makes
> ptelock contention with page fault. then, anon_vma_lock is holding
> long time and it makes another lock contention. then, fork/exit
> throughput decrease a lot.

It looks good to me.   Larry, does this patch series resolve
your issue?

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
