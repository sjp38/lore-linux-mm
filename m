Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 75A5C6B0082
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 04:41:11 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o139f4W6031130
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 09:41:05 GMT
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by wpaz17.hot.corp.google.com with ESMTP id o139f2Wd002723
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 01:41:03 -0800
Received: by pzk30 with SMTP id 30so996194pzk.11
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 01:41:02 -0800 (PST)
Date: Wed, 3 Feb 2010 01:40:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <20100203164612.D3AC.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002030131330.11389@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <20100203164612.D3AC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, KOSAKI Motohiro wrote:

> Personally, I think your use case represent to typical desktop and Linux
> have to works fine on typical desktop use-case. /proc/pid/oom_adj never fit
> desktop use-case. In past discussion, I'v agreed with much people. but I haven't
> reach to agree with David Rientjes about this topic.
> 

Which point don't you agree with?  I've agreed that heuristic needs to be 
changed and since Kame has decided to abandon his oom killer work, I said 
that I would find time to develop a solution that would be based on 
consensus.  I don't think that simply replacing the baseline with rss, 
rendering oom_adj practically useless for any other purpose other than 
polarizing priorities, and removing any penalty for tasks that fork an 
egregious amount of tasks is acceptable to all parties, though.

When a desktop system runs a vital task that, at all costs, cannot 
possibly be oom killed such as KDE from the user perspective, is it really 
that outrageous of a request to set it to OOM_DISABLE?  No, it's not.  
There are plenty of open source examples of applications that tune their 
own oom_adj values for that reason; userspace input into the oom killer's 
heuristic will always be an integral part of its function.

I believe that we can reach consensus without losing the existing 
functionality that oom_adj provides, namely defining vital system tasks 
and memory leakers, and without this all or nothing type attitude that 
insists we either go with rss as a baseline because "it doesn't select X 
first in my particular example" or you'll just take your ball and go home.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
