Date: Thu, 21 Feb 2008 18:44:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080221184450.c30f24d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47BD4438.4030203@linux.vnet.ibm.com>
References: <47BC10A8.4020508@linux.vnet.ibm.com>
	<20080221.114929.42336527.taka@valinux.co.jp>
	<20080221153536.09c28f44.kamezawa.hiroyu@jp.fujitsu.com>
	<20080221.180745.74279466.taka@valinux.co.jp>
	<20080221182156.63e5fc25.kamezawa.hiroyu@jp.fujitsu.com>
	<47BD4438.4030203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2008 14:58:24 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > But yes. I'm afraid of lock contention very much. I'll find another lock-less way
> > if necessary. One idea is map each area like sparsemem_vmemmap for 64bit systems.
> > Now, I'm convinced that it will be complicated ;)
> > 
> 
> The radix tree base is lockless (it uses RCU), so we might have a partial
> solution to the locking problem. But it's unchartered territory, so no one knows.
> 
> > I'd like to start from easy way and see performance.
> > 
> 
> Sure, please keep me in the loop as well.
> 
Okay, I'll do my best.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
