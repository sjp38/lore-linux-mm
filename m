Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 357CD8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 22:20:52 -0500 (EST)
Message-ID: <4D6F077B.3060400@tao.ma>
Date: Thu, 03 Mar 2011 11:14:03 +0800
From: Tao Ma <tm@tao.ma>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/5] mm: Add hit/miss accounting for Page Cache
References: <no> <1299055090-23976-4-git-send-email-namei.unix@gmail.com> <20110302084542.GA20795@elte.hu>
In-Reply-To: <20110302084542.GA20795@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Liu Yuan <namei.unix@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@redhat.com>

On 03/02/2011 04:45 PM, Ingo Molnar wrote:
> * Liu Yuan<namei.unix@gmail.com>  wrote:
>
>    
>> +		if (likely(!retry_find)&&  page&&  PageUptodate(page))
>> +			page_cache_acct_hit(inode->i_sb, READ);
>> +		else
>> +			page_cache_acct_missed(inode->i_sb, READ);
>>      
> Sigh.
>
> This would make such a nice tracepoint or sw perf event. It could be collected in a
> 'count' form, equivalent to the stats you are aiming for here, or it could even be
> traced, if someone is interested in such details.
>
> It could be mixed with other events, enriching multiple apps at once.
>
> But, instead of trying to improve those aspects of our existing instrumentation
> frameworks, mm/* is gradually growing its own special instrumentation hacks, missing
> the big picture and fragmenting the instrumentation space some more.
>    
Thanks for the quick response. Actually our team(including Liu) here are 
planing to add some
debug info to the mm parts for analyzing the application behavior and 
hope to find some way
to improve our application's performance.
We have searched the trace points in mm, but it seems to us that the 
trace points isn't quite welcomed
there. Only vmscan and writeback have some limited trace points added. 
That's the reason we first
tried to add some debug info like this patch. You does shed some light 
on our direction. Thanks.

btw, what part do you think is needed to add some trace point?  We 
volunteer to add more if you like.

Regards,
Tao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
