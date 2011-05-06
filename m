Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 70AB96B0025
	for <linux-mm@kvack.org>; Fri,  6 May 2011 13:28:02 -0400 (EDT)
Message-ID: <4DC42644.5020500@redhat.com>
Date: Fri, 06 May 2011 12:48:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] VM/RMAP: Batch anon_vma_unlink in exit
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org> <1304623972-9159-4-git-send-email-andi@firstfloor.org>
In-Reply-To: <1304623972-9159-4-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie, Andi Kleen <ak@linux.intel.com>

On 05/05/2011 03:32 PM, Andi Kleen wrote:
> From: Andi Kleen<ak@linux.intel.com>
>
> Apply the rmap chain lock batching to anon_vma_unlink() too.
> This speeds up exit() on process chains with many processes,
> when there is a lot of sharing.
>
> Unfortunately this doesn't fix all lock contention -- file vmas
> have a mapping lock that is also a problem. And even existing
> anon_vmas still contend. But it's better than before.
>
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
