Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAC4B6B002D
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 13:24:14 -0500 (EST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 16 Nov 2011 23:54:10 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAGIO4Fs4681788
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 23:54:04 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAGIO46L020379
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 05:24:04 +1100
Message-ID: <4EC3FFC4.2010904@linux.vnet.ibm.com>
Date: Wed, 16 Nov 2011 23:54:04 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] PM/Memory-hotplug: Avoid task freezing failures
References: <20111116115515.25945.35368.stgit@srivatsabhat.in.ibm.com> <20111116162601.GB18919@google.com> <4EC3F146.7050801@linux.vnet.ibm.com> <20111116174302.GD18919@google.com>
In-Reply-To: <20111116174302.GD18919@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 11/16/2011 11:13 PM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Nov 16, 2011 at 10:52:14PM +0530, Srivatsa S. Bhat wrote:
>> So, honestly I didn't understand what is wrong with the approach of this
>> patch. And as a consequence, I don't see why we should wait to fix this
>> issue. 
>>
>> [And by the way recently I happened to see yet another proposed patch
>> trying to make use of this API. So wouldn't it be better to fix this
>> ASAP, especially when we have a fix readily available?]
> 
> It just doesn't look like a proper solution.  Nothing guarantees
> freezing will happen soonish.  Not all pm operations involve freezer.
> The exclusion is against mem hotplug at this point, right?  I don't
> think it's a good idea to add such hack to fix a mostly theoretical
> problem and it's actually quite likely someone would be scratching
> head trying to figure out why the hell the CPU was hot spinning while
> the system is trying to enter one of powersaving mode (we had similar
> behavior in freezer code a while back and it was ugly).
> 
> So, let's either fix it properly or leave it alone.
> 

Ok, so by "proper solution", are you referring to a totally different
method (than grabbing pm_mutex) to implement mutual exclusion between
subsystems and suspend/hibernation, something like the suspend blockers
stuff and friends? 
Or are you hinting at just the existing code itself being fixed more
properly than what this patch does, to avoid having side effects like
you pointed out?

I am just trying to figure out what would be the best way to proceed here.
By the way I consider it lucky that we have spotted this bug before we
actually hit it.. So I would really love to get this fixed before it
comes back to haunt us in the future ;-)

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
