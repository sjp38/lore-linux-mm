Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3A0CB6B0011
	for <linux-mm@kvack.org>; Fri,  6 May 2011 13:38:08 -0400 (EDT)
Message-ID: <4DC42735.7010306@redhat.com>
Date: Fri, 06 May 2011 12:52:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] VM/RMAP: Move avc freeing outside the lock
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org> <1304623972-9159-5-git-send-email-andi@firstfloor.org>
In-Reply-To: <1304623972-9159-5-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie, Andi Kleen <ak@linux.intel.com>

On 05/05/2011 03:32 PM, Andi Kleen wrote:
> From: Andi Kleen<ak@linux.intel.com>
>
> Now that the avc locking is batched move the freeing of AVCs
> outside the lock. This lowers lock contention somewhat more on
> a fork/exit intensive workload.
>
> Signed-off-by: Andi Kleen<ak@linux.intel.com>

Acked-by: Rik van Riel<riel@redhat.com>

I believe that calling put_anon_vma outside of the lock is
safe, but am not 100% sure.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
