Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4EC6B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 18:24:01 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so18745796pde.13
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 15:24:00 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id ob10si56338887pbb.37.2014.01.06.15.23.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 15:23:59 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 09:23:54 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 1DD6D2CE8053
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 10:23:51 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s06N55CC48693454
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 10:05:06 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s06NNn4b020170
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 10:23:49 +1100
Date: Tue, 7 Jan 2014 07:23:48 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] sched/auto_group: fix consume memory even if add
 'noautogroup' in the cmdline
Message-ID: <52cb3b0f.2a82440a.5285.ffff9642SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1388139751-19632-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20140106121719.GH31570@twins.programming.kicks-ass.net>
 <1389016976.5536.10.camel@marge.simpson.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389016976.5536.10.camel@marge.simpson.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <bitbucket@online.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 06, 2014 at 03:02:56PM +0100, Mike Galbraith wrote:
>On Mon, 2014-01-06 at 13:17 +0100, Peter Zijlstra wrote: 
>> On Fri, Dec 27, 2013 at 06:22:31PM +0800, Wanpeng Li wrote:
>> > We have a server which have 200 CPUs and 8G memory, there is auto_group creation 
>> 
>> I'm hoping that is 8T, otherwise that's a severely under provisioned
>> system, that's a mere 40M per cpu, does that even work?
>> 
>> > which will almost consume 12MB memory even if add 'noautogroup' in the kernel 
>> > boot parameter. In addtion, SLUB per cpu partial caches freeing that is local to 
>> > a processor which requires the taking of locks at the price of more indeterminism 
>> > in the latency of the free. This patch fix it by check noautogroup earlier to avoid 
>> > free after unnecessary memory consumption.
>> 
>> That's just a bad changelog. It fails to explain the actual problem and
>> it babbles about unrelated things like SLUB details.
>> 
>> Also, I'm not entirely sure what the intention was of this code, I've so
>> far tried to ignore the entire autogroup fest... 
>> 
>> It looks like it creates and maintains the entire autogroup hierarchy,
>> such that if you at runtime enable the sysclt and move tasks 'back' to
>> the root cgroup you get the autogroup behaviour.
>> 
>> Was this intended? Mike?
>
>Yeah, it was intended that autogroups always exist if you config it in.
>We could make is such that noautogroup makes it irreversibly off/dead.  
>
>People with 200 ram starved CPUs can turn it off in their .config too :)

Thanks for your great explaination. 

Regards,
Wanpeng Li 

>
>-Mike
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
