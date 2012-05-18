Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 6B8546B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 04:34:42 -0400 (EDT)
Message-ID: <4FB609CF.3060307@kernel.org>
Date: Fri, 18 May 2012 17:35:27 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <1337133919-4182-3-git-send-email-minchan@kernel.org> <4FB4B29C.4010908@kernel.org> <20120517144622.GA27597@kroah.com>
In-Reply-To: <20120517144622.GA27597@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, a.p.zijlstra@chello.nl, Nick Piggin <npiggin@gmail.com>

Hi Greg,

On 05/17/2012 11:46 PM, Greg Kroah-Hartman wrote:

> On Thu, May 17, 2012 at 05:11:08PM +0900, Minchan Kim wrote:
>> Isn't there anyone for taking a time to review this patch? :)
>>
>> On 05/16/2012 11:05 AM, Minchan Kim wrote:
> 
> <snip>
> 
> You want review within 24 hours for a staging tree patch for a feature
> that no one uses?
> 
> That's very bold of you.  Please be realistic.


I admit I was hurry because I thought portability issue of zsmalloc may
be a urgent issue for [zram|zsmalloc] to go out of staging and I want to
move [zsmalloc|zram] into mainline as soon as possible.

I should have grown my patience.

As an excuse, exactly speaking, it's not 24 hours because I sent first
patch 5/14 and I didn't change that patch from then. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
