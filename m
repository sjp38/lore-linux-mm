Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E9F106B0011
	for <linux-mm@kvack.org>; Fri,  6 May 2011 12:00:00 -0400 (EDT)
Message-ID: <4DC41AE2.8060301@redhat.com>
Date: Fri, 06 May 2011 11:59:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap
 chain locking
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org> <1304623972-9159-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1304623972-9159-2-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie, Andi Kleen <ak@linux.intel.com>

On 05/05/2011 03:32 PM, Andi Kleen wrote:
> From: Andi Kleen<ak@linux.intel.com>
>
> In fork and exit it's quite common to take same rmap chain locks
> again and again when the whole address space is processed  for a
> address space that has a lot of sharing. Also since the locking
> has changed to always lock the root anon_vma this can be very
> contended.
>
> This patch adds a simple wrapper to batch these lock acquisitions
> and only reaquire the lock when another is needed. The main
> advantage is that when multiple processes are doing this in
> parallel they will avoid a lot of communication overhead
> on the lock cache line.
>
> I added a simple lock break (100 locks) for paranoia reason,
> but it's unclear if that's needed or not.
>
> Cc: Andrea Arcangeli<aarcange@redhat.com>
> Cc: Rik van Riel<riel@redhat.com>
> Signed-off-by: Andi Kleen<ak@linux.intel.com>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
