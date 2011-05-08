Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E9BF96B0012
	for <linux-mm@kvack.org>; Sun,  8 May 2011 17:29:46 -0400 (EDT)
Message-ID: <4DC70B45.3020503@redhat.com>
Date: Sun, 08 May 2011 17:29:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: memory: remove unreachable code
References: <20110508211834.GA4410@maxin>
In-Reply-To: <20110508211834.GA4410@maxin>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin B John <maxin.john@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, walken@google.com, aarcange@redhat.com, hughd@google.com, linux-mm@kvack.org

On 05/08/2011 05:18 PM, Maxin B John wrote:
> Remove the unreachable code found in mm/memory.c
>
> Signed-off-by: Maxin B. John<maxin.john@gmail.com>
> ---
> diff --git a/mm/memory.c b/mm/memory.c
> index 27f4253..d3b30af 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3695,7 +3695,6 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>   			if (ret<= 0)
>   #endif
>   				break;
> -			bytes = ret;
>   		} else {
>   			bytes = len;
>   			offset = addr&  (PAGE_SIZE-1);

Is it really impossible for vma->vm_ops->access to return a
positive value?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
