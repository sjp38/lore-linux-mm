Date: Tue, 9 Sep 2008 20:11:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/14]  memcg: lockless page cgroup
Message-Id: <20080909201115.b87f9bdb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080909171154.f3cfdfd6.nishimura@mxp.nes.nec.co.jp>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080909144007.48e6633a.nishimura@mxp.nes.nec.co.jp>
	<20080909165608.878d7182.kamezawa.hiroyu@jp.fujitsu.com>
	<20080909171154.f3cfdfd6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Sep 2008 17:11:54 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > I'm sorry to say that I'll have to postpone this to remove
> > page->page_cgroup pointer. I need some more performance-improvement
> > effort to remove page->page_cgroup pointer without significant overhead.
> > 
> No problem. I know about that :)
> 
This is the latest result of lockless series. (on rc5-mmtom)
(Don't trust shell script result...it seems too slow.)

==on 2cpu/1socket x86-64 host==
rc5-mm1
==
Execl Throughput                           3006.5 lps   (29.8 secs, 3 samples)
C Compiler Throughput                      1006.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (1 concurrent)               4863.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)                943.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               482.7 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places         124804.9 lpm   (30.0 secs, 3 samples)

lockless
==
Execl Throughput                           3035.5 lps   (29.6 secs, 3 samples)
C Compiler Throughput                      1010.3 lpm   (60.0 secs, 3 samples)
Shell Scripts (1 concurrent)               4881.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)                947.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               485.0 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places         125437.9 lpm   (30.0 secs, 3 samples)
==

I'll try to build "remove-page-cgroup-pointer" patch on this
and see what happens tomorrow. (And I think my 8cpu box will come back..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
