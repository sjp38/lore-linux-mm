Date: Thu, 27 Mar 2008 18:34:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] [PATCH 0/4] memcg : radix-tree page_cgroup v2
Message-Id: <20080327183415.166db9ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080327175654.C749.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com>
	<20080327175654.C749.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Thu, 27 Mar 2008 18:12:42 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> >          TEST                                BASELINE     RESULT      INDEX
> > (1)      Execl Throughput                        43.0     2868.8      667.2
> > (2)      Execl Throughput                        43.0     2810.3      653.6
> > (3)      Execl Throughput                        43.0     2836.9      659.7
> > (4)      Execl Throughput                        43.0     2846.0      661.9
> > (5)      Execl Throughput                        43.0     2862.0      665.6
> > (6)      Execl Throughput                        43.0     3110.0      723.3
> > 
> > (1) .... rc5-mm1 + memory controller
> > (2) .... patch 1/4 is applied.      (use radix-tree always.)
> > (3) .... patch [1-3]/4 are applied. (caching by percpu)
> > (4) .... patch [1-4]/4 are applied. (uses prefetch)
> > (5) .... adjust sizeof(struct page) to be 64 bytes by padding.
> > (6) .... rc5-mm1 *without* memory controller
> 
> I am very surprised this result. 
> 723.3 -> 667.2 seems large performance impact.
> 
> Why do you need count resource usage when unlimited limit.
> Could you separate unlimited group to resource usage counting and no counting.
> I hope default cgroup keep no counting and no decrease performance.

At first, I'd like to reduce this overhead even under memory resource
controller's accounting ;)
We have boot-time-disable option now. But it doesn't seem what you want.

Considering workaround....
In current system, *unlimited* doesn't mean *no account*.
So, I think we have an option to add "no account" flag per cgroup.

Hmm..some interface to do
- allow "no account" -> "account"
- disallow "account" -> "no account"

Balbir-san, how do you think ?


Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
