Date: Thu, 27 Mar 2008 18:12:42 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm] [PATCH 0/4] memcg : radix-tree page_cgroup v2
In-Reply-To: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080327175654.C749.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Hi

>          TEST                                BASELINE     RESULT      INDEX
> (1)      Execl Throughput                        43.0     2868.8      667.2
> (2)      Execl Throughput                        43.0     2810.3      653.6
> (3)      Execl Throughput                        43.0     2836.9      659.7
> (4)      Execl Throughput                        43.0     2846.0      661.9
> (5)      Execl Throughput                        43.0     2862.0      665.6
> (6)      Execl Throughput                        43.0     3110.0      723.3
> 
> (1) .... rc5-mm1 + memory controller
> (2) .... patch 1/4 is applied.      (use radix-tree always.)
> (3) .... patch [1-3]/4 are applied. (caching by percpu)
> (4) .... patch [1-4]/4 are applied. (uses prefetch)
> (5) .... adjust sizeof(struct page) to be 64 bytes by padding.
> (6) .... rc5-mm1 *without* memory controller

I am very surprised this result. 
723.3 -> 667.2 seems large performance impact.

Why do you need count resource usage when unlimited limit.
Could you separate unlimited group to resource usage counting and no counting.
I hope default cgroup keep no counting and no decrease performance.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
