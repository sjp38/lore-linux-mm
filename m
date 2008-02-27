Date: Wed, 27 Feb 2008 15:52:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
In-Reply-To: <47C4F9C0.5010607@linux.vnet.ibm.com>
References: <alpine.DEB.1.00.0802262145410.31356@chino.kir.corp.google.com> <47C4F9C0.5010607@linux.vnet.ibm.com>
Message-Id: <20080227153614.425B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi

> Things are changing, with memory hot-add remove, CPU hotplug , the topology can
> change and is no longer static. One can create fake NUMA nodes on the fly using
> a boot option as well.

agreed.

> Since we're talking of parallel reclaims, I think it's a function of CPUs and
> Nodes. I'd rather keep it as a sysctl with a good default value based on the
> topology. If we end up getting it wrong, the system administrator has a choice.
> That is better than expecting him/her to recompile the kernel and boot that. A
> sysctl does not create problems either w.r.t changing the number of threads, no
> hard to solve race-conditions - it is fairly straight forward

sorry, I don't understand yet.
I think my patch is already function of CPUs and Nodes.
per zone limit indicate propotional #cpus and #nodes.

please tell me the topology that per zone limit doesn't works so good.

I think boot option and sysctl should be used only while -mm
for get various feedback.
end up, we should select more better default, and remove sysctl.


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
