Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE186B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 16:08:21 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o1OL8HtG031238
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 21:08:17 GMT
Received: from pwi2 (pwi2.prod.google.com [10.241.219.2])
	by kpbe13.cbf.corp.google.com with ESMTP id o1OL7E48027417
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 15:08:16 -0600
Received: by pwi2 with SMTP id 2so2356301pwi.12
        for <linux-mm@kvack.org>; Wed, 24 Feb 2010 13:08:16 -0800 (PST)
Date: Wed, 24 Feb 2010 13:08:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <4B84F2FD.6030605@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002241307040.30870@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <4B827043.3060305@cn.fujitsu.com>
 <alpine.DEB.2.00.1002221339160.14426@chino.kir.corp.google.com> <4B838490.1050908@cn.fujitsu.com> <alpine.DEB.2.00.1002230046160.12015@chino.kir.corp.google.com> <4B839E9D.8020604@cn.fujitsu.com> <alpine.DEB.2.00.1002231427190.8693@chino.kir.corp.google.com>
 <4B84F2FD.6030605@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Feb 2010, Miao Xie wrote:

> I think it is not a big deal because it is safe and doesn't cause any problem.
> Beside that, task->cpus_allowed is initialized to cpu_possible_mask on the no-cpuset
> kernel, so using cpu_possible_mask to initialize task->cpus_allowed is reasonable.
> (top cpuset is a special cpuset, isn't it?)
>  

I'm suprised that I can create a descendant cpuset of top_cpuset that 
cannot include all of its parents' cpus and that the root cpuset's cpus 
mask doesn't change when cpus are onlined/offlined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
