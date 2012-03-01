Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 967256B004D
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 17:40:31 -0500 (EST)
Date: Thu, 1 Mar 2012 14:40:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V2 0/9] memcg: add HugeTLB resource tracking
Message-Id: <20120301144029.545a5589.akpm@linux-foundation.org>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>

On Thu,  1 Mar 2012 14:46:11 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> This patchset implements a memory controller extension to control
> HugeTLB allocations. It is similar to the existing hugetlb quota
> support in that, the limit is enforced at mmap(2) time and not at
> fault time. HugeTLB's quota mechanism limits the number of huge pages
> that can allocated per superblock.
> 
> For shared mappings we track the regions mapped by a task along with the
> memcg. We keep the memory controller charged even after the task
> that did mmap(2) exits. Uncharge happens during truncate. For Private
> mappings we charge and uncharge from the current task cgroup.

I haven't begin to get my head around this yet, but I'd like to draw
your attention to https://lkml.org/lkml/2012/2/15/548.  That fix has
been hanging around for a while, but I haven't done anything with it
yet because I don't like its additional blurring of the separation
between hugetlb core code and hugetlbfs.  I want to find time to sit
down and see if the fix can be better architected but haven't got
around to that yet.

I expect that your patches will conflict at least mechanically with
David's, which is not a big issue.  But I wonder whether your patches
will copy the same bug into other places, and whether you can think of
a tidier way of addressing the bug which David is seeing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
