Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 42F886B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:26:55 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6620619dak.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 13:26:54 -0700 (PDT)
Date: Sat, 16 Jun 2012 13:26:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -V6 07/14] memcg: Add HugeTLB extension
In-Reply-To: <CAGr1F2EzDc3Ypv6twFE8Ua-JZUEkEVQJOPKwLt0O56c2-PycvA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1206161322310.8407@chino.kir.corp.google.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1334573091-18602-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <alpine.DEB.2.00.1205241436180.24113@chino.kir.corp.google.com> <20120527202848.GC7631@skywalker.linux.vnet.ibm.com>
 <87lik920h8.fsf@skywalker.in.ibm.com> <20120608160612.dea6d1ce.akpm@linux-foundation.org> <4FD56C19.4060307@jp.fujitsu.com> <alpine.DEB.2.00.1206110220290.6843@chino.kir.corp.google.com> <CAGr1F2EzDc3Ypv6twFE8Ua-JZUEkEVQJOPKwLt0O56c2-PycvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aditya Kali <adityakali@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Ying Han <yinghan@google.com>

On Fri, 15 Jun 2012, Aditya Kali wrote:

> Based on the usecase at Google, I see a definite value in including
> hugepage usage in memory.usage_in_bytes as well and having a single
> limit for memory usage for the job. Our jobs wants to specify only one
> (total) memory limit (including slab usage, and other kernel memory
> usage, hugepages, etc.).
> 
> The hugepage/smallpage requirements of the job vary during its
> lifetime. Having two different limits means less flexibility for jobs
> as they now have to specify their limit as (max_hugepage,
> max_smallpage) instead of max(hugepage + smallpage). Two limits
> complicates the API for the users and requires them to over-specify
> the resources.
> 

If a large number of hugepages, for example, are allocated on the command 
line because there's a lower success rate of dynamic allocation due to 
fragmentation, with your suggestion it would no longer allow the admin to 
restrict the use of those hugepages to only a particular set of tasks.  
Consider especially 1GB hugepagez on x86, your suggestion would treat a 
single 1GB hugepage which cannot be freed after boot exactly the same as 
using 1GB of memory which is obviously not the desired behavior of any 
hugetlb controller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
