Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 25A496B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 16:53:43 -0400 (EDT)
Message-ID: <4F85EEED.1090906@parallels.com>
Date: Wed, 11 Apr 2012 17:51:57 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove BUG() in possible but rare condition
References: <1334167824-19142-1-git-send-email-glommer@parallels.com> <20120411132635.bfddc6bd.akpm@linux-foundation.org>
In-Reply-To: <20120411132635.bfddc6bd.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 04/11/2012 05:26 PM, Andrew Morton wrote:
>>
>> >    failed:
>> >  -	BUG();
>> >    	unlock_page(page);
>> >    	page_cache_release(page);
>> >    	return NULL;
> Cute.
>
> AFAICT what happened was that in my April 2002 rewrite of this code I
> put a non-fatal buffer_error() warning in that case to tell us that
> something bad happened.
>
> Years later we removed the temporary buffer_error() and mistakenly
> replaced that warning with a BUG().  Only it*can*  happen.
>
> We can remove the BUG() and fix up callers, or we can pass retry=1 into
> alloc_page_buffers(), so grow_dev_page() "cannot fail".  Immortal
> functions are a silly fiction, so we should remove the BUG() and fix up
> callers.
>
Any particular caller you are concerned with ?

As I mentioned, this function already returns NULL for other reason - 
that seem even more probable than this specific failure. So whoever is
not checking this return value, is already broken without this patch as 
well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
