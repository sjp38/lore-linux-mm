Date: Mon, 1 Sep 2008 11:39:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080901113918.b6f05ca6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080831174756.GA25790@balbir.in.ibm.com>
References: <20080831174756.GA25790@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 31 Aug 2008 23:17:56 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> This is a rewrite of a patch I had written long back to remove struct page
> (I shared the patches with Kamezawa, but never posted them anywhere else).
> I spent the weekend, cleaning them up for 2.6.27-rc5-mmotm (29 Aug 2008).
> 
> I've tested the patches on an x86_64 box, I've run a simple test running
> under the memory control group and the same test running concurrently under
> two different groups (and creating pressure within their groups). I've also
> compiled the patch with CGROUP_MEM_RES_CTLR turned off.
> 
> Advantages of the patch
> 
> 1. It removes the extra pointer in struct page
> 
> Disadvantages
> 
> 1. It adds an additional lock structure to struct page_cgroup
> 2. Radix tree lookup is not an O(1) operation, once the page is known
>    getting to the page_cgroup (pc) is a little more expensive now.
> 
> This is an initial RFC for comments
> 
> TODOs
> 
> 1. Test the page migration changes
> 2. Test the performance impact of the patch/approach
> 
> Comments/Reviews?
> 
BTW, how deep this radix-tree on 4GB/32GB/64GB/256GB machine ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
