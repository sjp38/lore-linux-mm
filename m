Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 08B2E6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 15:13:04 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p4RJD1qw013021
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:13:01 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe16.cbf.corp.google.com with ESMTP id p4RJCxvs021419
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:13:00 -0700
Received: by pxi19 with SMTP id 19so1504643pxi.1
        for <linux-mm@kvack.org>; Fri, 27 May 2011 12:12:59 -0700 (PDT)
Date: Fri, 27 May 2011 12:12:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
In-Reply-To: <241133039.238335.1306393713338.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1105271211050.2533@chino.kir.corp.google.com>
References: <241133039.238335.1306393713338.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, kamezawa hiroyu <kamezawa.hiroyu@jp.fujitsu.com>, minchan kim <minchan.kim@gmail.com>, oleg@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, 26 May 2011, CAI Qian wrote:

> Here is the results for the testing. Running the reproducer as non-root
> user, the results look good as OOM killer just killed each python process
> in-turn that the reproducer forked. However, when running it as root
> user, sshd and other random processes had been killed.
> 

Thanks for testing!  The patch that I proposed for you was a little more 
conservative in terms of providing a bonus to root processes that aren't 
using a certain threshold of memory.  My latest proposal was to give root 
processes only a 1% bonus for every 10% of memory they consume, so it 
would be impossible for them to have an oom score of 1 as reported in your 
logs.

I believe that KOSAKI-san is refreshing his series of patches, so let's 
look at how your workload behaves on the next iteration.  Thanks CAI!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
