Subject: Re: [RFC][PATCH] page reclaim throttle take2
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <47C526F8.8010807@linux.vnet.ibm.com>
References: <47C4EF2D.90508@linux.vnet.ibm.com>
	 <alpine.DEB.1.00.0802262115270.1799@chino.kir.corp.google.com>
	 <20080227143301.4252.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <alpine.DEB.1.00.0802262145410.31356@chino.kir.corp.google.com>
	 <47C4F9C0.5010607@linux.vnet.ibm.com>
	 <alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com>
	 <47C51856.7060408@linux.vnet.ibm.com>
	 <alpine.DEB.1.00.0802270045400.31372@chino.kir.corp.google.com>
	 <47C526F8.8010807@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Wed, 27 Feb 2008 10:44:58 +0100
Message-Id: <1204105498.6242.374.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-27 at 14:31 +0530, Balbir Singh wrote:

> You mentioned CONFIG_NUM_RECLAIM_THREADS_PER_CPU and not
> CONFIG_NUM_RECLAIM_THREADS_PER_NODE. The advantage with syscalls is that even if
> we get the thing wrong, the system administrator has an alternative. Please look
> through the existing sysctl's and you'll see what I mean. What is wrong with
> providing the flexibility that comes with sysctl? We cannot possibly think of
> all situations and come up with the right answer for a heuristic. Why not come
> up with a default and let everyone use what works for them?

I agree with Balbir, just turn it into a sysctl, its easy enough to do,
and those who need it will thank you for it instead of curse you for
hard coding it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
