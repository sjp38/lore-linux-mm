Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 866016B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 16:48:40 -0500 (EST)
Message-ID: <4F304A9B.2030004@redhat.com>
Date: Mon, 06 Feb 2012 16:48:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] compact_pgdat: workaround lockdep warning in kswapd
References: <alpine.LSU.2.00.1202061129040.2144@eggly.anvils> <20120206124952.75702d5c.akpm@linux-foundation.org>
In-Reply-To: <20120206124952.75702d5c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org

On 02/06/2012 03:49 PM, Andrew Morton wrote:
> On Mon, 6 Feb 2012 11:40:08 -0800 (PST)
> Hugh Dickins<hughd@google.com>  wrote:
>
>> I get this lockdep warning from swapping load on linux-next
>> (20120201 but I expect the same from more recent days):
>
> The patch looks good as a standalone optimisation/cleanup.  The lack of
> clarity on the lockdep thing is a concern - I have a feeling we'll be
> bitten again.

Very strange, kswapd does not seem to be holding any locks
when calling balance_pgdat...

I assume it must be this line in kswapd() that's causing
lockdep to trigger:

	lockdep_set_current_reclaim_state(GFP_KERNEL);

> This fix seems to be applicable to mainline?


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
