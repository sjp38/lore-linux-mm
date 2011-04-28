Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E370E6B002B
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:52:29 -0400 (EDT)
Message-ID: <4DB98D13.1050107@kpanic.de>
Date: Thu, 28 Apr 2011 17:51:47 +0200
From: Stefan Assmann <sassmann@kpanic.de>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/3] support for broken memory modules (BadRAM)
References: <1303921007-1769-1-git-send-email-sassmann@kpanic.de> <1303921007-1769-3-git-send-email-sassmann@kpanic.de> <20110427211258.GQ16484@one.firstfloor.org> <4DB90A66.3020805@kpanic.de> <20110428150821.GT16484@one.firstfloor.org>
In-Reply-To: <20110428150821.GT16484@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, tony.luck@intel.com, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org, lwoodman@redhat.com, riel@redhat.com

On 04/28/2011 05:08 PM, Andi Kleen wrote:
>> You're right, logging every page marked would be too verbose. That's why
>> I wrapped that logging into pr_debug.
>
> pr_debug still floods the kernel log buffer. On large systems
> it often already overflows.

That's a pain then, I understand.

>
>> However I kept the printk in the case of early allocated pages. The user
>> should be notified of the attempt to mark a page that's already been
>> allocated by the kernel itself.
>
> That's ok, although if you're unlucky (e.g. hit a large mem_map area)
> it can be also very nosiy.
>
> It would be better if you fixed the printks to output ranges.

BadRAM patterns might often mark non-consecutive pages so outputting
ranges could be more verbose than what we have now. I'll try to think
of something to minimize log output.

   Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
