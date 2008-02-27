Date: Tue, 26 Feb 2008 21:47:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
In-Reply-To: <20080227143301.4252.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0802262145410.31356@chino.kir.corp.google.com>
References: <47C4EF2D.90508@linux.vnet.ibm.com> <alpine.DEB.1.00.0802262115270.1799@chino.kir.corp.google.com> <20080227143301.4252.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008, KOSAKI Motohiro wrote:

> > I disagree, the config option is indeed static but so is the NUMA topology 
> > of the machine.  It represents the maximum number of page reclaim threads 
> > that should be allowed for that specific topology; a maximum should not 
> > need to be redefined with yet another sysctl and should remain independent 
> > of various workloads.
> 
> ok.
> 
> > However, I would recommend adding the word "MAX" to the config option.
> 
> MAX_PARALLEL_RECLAIM_TASK is good word?
> 

I'd use _THREAD instead of _TASK, but I'd also wait for Balbir's input 
because perhaps I missed something in my original analysis that this 
config option represents only the maximum number of concurrent reclaim 
threads and other heuristics are used in addition to this that determine 
the exact number of threads depending on VM strain.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
