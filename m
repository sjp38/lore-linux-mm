Date: Wed, 3 Sep 2008 12:33:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080903123306.316beb9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48BD337E.40001@linux.vnet.ibm.com>
References: <20080831174756.GA25790@balbir.in.ibm.com>
	<200809011656.45190.nickpiggin@yahoo.com.au>
	<20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	<200809011743.42658.nickpiggin@yahoo.com.au>
	<48BD0641.4040705@linux.vnet.ibm.com>
	<20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD0E4A.5040502@linux.vnet.ibm.com>
	<20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD119B.8020605@linux.vnet.ibm.com>
	<20080902195717.224b0822.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD337E.40001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 02 Sep 2008 18:07:18 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> I understand your concern and I am not trying to reduce memcg's performance - or
> add a fancy feature. I am trying to make memcg more friendly for distros. I see
> your point about the overhead. I just got back my results - I see a 4% overhead
> with the patches. Let me see if I can rework them for better performance.
> 
Just an idea, by using atomic_ops page_cgroup patch, you can encode page_cgroup->lock
to page_cgroup->flags and use bit_spinlock(), I think.
(my new patch set use bit_spinlock on page_cgroup->flags for avoiding some race.)

This will save extra 4 bytes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
