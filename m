Date: Tue, 9 Sep 2008 13:55:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080909135511.945b9c97.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48C5F91D.5070500@linux.vnet.ibm.com>
References: <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	<200809011743.42658.nickpiggin@yahoo.com.au>
	<48BD0641.4040705@linux.vnet.ibm.com>
	<20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD0E4A.5040502@linux.vnet.ibm.com>
	<20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD119B.8020605@linux.vnet.ibm.com>
	<20080902195717.224b0822.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD337E.40001@linux.vnet.ibm.com>
	<20080903123306.316beb9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20080908152810.GA12065@balbir.in.ibm.com>
	<20080909125751.37042345.kamezawa.hiroyu@jp.fujitsu.com>
	<48C5F91D.5070500@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 08 Sep 2008 21:18:37 -0700
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Mon, 8 Sep 2008 20:58:10 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> Sorry for the delay in sending out the new patch, I am traveling and
> >> thus a little less responsive. Here is the update patch
> >>
> >>
> > Hmm.. I've considered this approach for a while and my answer is that
> > this is not what you really want.
> > 
> > Because you just moves the placement of pointer from memmap to
> > radix_tree both in GFP_KERNEL, total kernel memory usage is not changed.
> 
> Agreed, but we do reduce the sizeof(struct page) without adding on to
> page_cgroup's size. So why don't we want this?
> 
> > So, at least, you have to add some address calculation (as I did in March)
> > to getting address of page_cgroup.
> 
> What address calculation do we need, sorry I don't recollect it.
> 
   base_address = base_addrees_of_page_group_chunk_of_pfn.
   base_address + offset_of_pfn_from_base_pfn * sizeof (struct page_cgroup).

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
