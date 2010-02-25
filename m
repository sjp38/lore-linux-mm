Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D15696B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 20:18:38 -0500 (EST)
Message-ID: <4B85CFD6.6010904@cn.fujitsu.com>
Date: Thu, 25 Feb 2010 09:18:14 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time (58568d2)
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <4B827043.3060305@cn.fujitsu.com> <alpine.DEB.2.00.1002221339160.14426@chino.kir.corp.google.com> <4B838490.1050908@cn.fujitsu.com> <alpine.DEB.2.00.1002230046160.12015@chino.kir.corp.google.com> <4B839E9D.8020604@cn.fujitsu.com> <alpine.DEB.2.00.1002231427190.8693@chino.kir.corp.google.com> <4B84F2FD.6030605@cn.fujitsu.com> <alpine.DEB.2.00.1002241307040.30870@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002241307040.30870@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

on 2010-2-25 5:08, David Rientjes wrote:
> On Wed, 24 Feb 2010, Miao Xie wrote:
> 
>> I think it is not a big deal because it is safe and doesn't cause any problem.
>> Beside that, task->cpus_allowed is initialized to cpu_possible_mask on the no-cpuset
>> kernel, so using cpu_possible_mask to initialize task->cpus_allowed is reasonable.
>> (top cpuset is a special cpuset, isn't it?)
>>  
> 
> I'm suprised that I can create a descendant cpuset of top_cpuset that 
> cannot include all of its parents' cpus and that the root cpuset's cpus 
> mask doesn't change when cpus are onlined/offlined.
> 

top cpuset's cpus is consistent with cpu_online_mask because the kernel changes it
when doing cpu hotplug. So the problem which you said doesn't exist.

Just cpus_allowed of all tasks in the top cpuset is initialized to cpu_possible_mask
in order to avoid updating them when doing cpu hotplug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
