Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CFBC66B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 12:12:42 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 21 Nov 2011 22:42:34 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pALHCUiM4640794
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 22:42:31 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pALHCUPg016296
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 22:42:30 +0530
Message-ID: <4ECA867D.4050901@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2011 22:42:29 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com> <201111192257.19763.rjw@sisk.pl> <20111121164758.GC15314@google.com>
In-Reply-To: <20111121164758.GC15314@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 11/21/2011 10:17 PM, Tejun Heo wrote:
> Hello, Rafael.
> 
> On Sat, Nov 19, 2011 at 10:57:19PM +0100, Rafael J. Wysocki wrote:
>>> +	while (!mutex_trylock(&pm_mutex)) {
>>> +		try_to_freeze();
>>> +		msleep(10);
>>
>> The number here seems to be somewhat arbitrary.  Is there any reason not to
>> use 100 or any other number?
> 
> This is a bit moot at this point but, at least for me, yeah, it's a
> number I pulled out of my ass.  That said, I think it's a good number
> to pull out of ass for userland visible retry delays for the following
> reasons.
> 
> * It's a good number - 10! which happens to match the number of
>   fingers I have!  Isn't that just weird? @.@
> 
> * For modern hardware of most classes, repeating not-so-complex stuff
>   every 10ms for a while isn't taxing (or even noticeable) at all.
> 
> * Sub 10ms delays usually aren't noticeable to human beings even when
>   several of them are staggered.  This is very different when you get
>   to 100ms range.
> 
> ie. going from 1ms to 10ms doesn't cost you too much in terms of human
> noticeable latency (for this type of situations anyway) but going from
> 10ms to 100ms does.  In terms of computational cost, the reverse is
> somewhat true too.  So, yeah, I think 10ms is a good out-of-ass number
> for this type of delays.
> 

My God! I had absolutely no idea you had cooked up that number just like
that ;-) Look at how creative I was when defending that number :P
Your justification is not bad either ;-)

[ Well, seriously, I had given a fair amount of thought before incorporating
that number in my patch, by looking at the freezer re-try latency and so on,
which I explained in my reply earlier.]

Anyways, nice one :-)

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
