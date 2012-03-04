Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E8DCE6B00F3
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 14:16:12 -0500 (EST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 00:46:08 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q24JG3fd4644878
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 00:46:04 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q24JG2IA024822
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 00:46:03 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V2 0/9] memcg: add HugeTLB resource tracking
In-Reply-To: <20120301144029.545a5589.akpm@linux-foundation.org>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120301144029.545a5589.akpm@linux-foundation.org>
Date: Mon, 05 Mar 2012 00:45:55 +0530
Message-ID: <878vjgdvo4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>

On Thu, 1 Mar 2012 14:40:29 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu,  1 Mar 2012 14:46:11 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > This patchset implements a memory controller extension to control
> > HugeTLB allocations. It is similar to the existing hugetlb quota
> > support in that, the limit is enforced at mmap(2) time and not at
> > fault time. HugeTLB's quota mechanism limits the number of huge pages
> > that can allocated per superblock.
> > 
> > For shared mappings we track the regions mapped by a task along with the
> > memcg. We keep the memory controller charged even after the task
> > that did mmap(2) exits. Uncharge happens during truncate. For Private
> > mappings we charge and uncharge from the current task cgroup.
> 
> I haven't begin to get my head around this yet, but I'd like to draw
> your attention to https://lkml.org/lkml/2012/2/15/548.

Hmm that's really serious bug.

>  That fix has
> been hanging around for a while, but I haven't done anything with it
> yet because I don't like its additional blurring of the separation
> between hugetlb core code and hugetlbfs.  I want to find time to sit
> down and see if the fix can be better architected but haven't got
> around to that yet.
> 
> I expect that your patches will conflict at least mechanically with
> David's, which is not a big issue.  But I wonder whether your patches
> will copy the same bug into other places, and whether you can think of
> a tidier way of addressing the bug which David is seeing?
> 

I will go through the implementation again and make sure the problem
explained by David doesn't happen in the new code path added by the
patch series.

Thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
