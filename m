Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 2FE566B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 11:04:32 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 10 Jun 2012 20:34:21 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5AF4HrB3277206
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 20:34:18 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5AKY4Xl022019
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:34:05 +1000
Date: Sun, 10 Jun 2012 20:34:10 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V6 07/14] memcg: Add HugeTLB extension
Message-ID: <20120610150410.GA11204@skywalker.linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1334573091-18602-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1205241436180.24113@chino.kir.corp.google.com>
 <20120527202848.GC7631@skywalker.linux.vnet.ibm.com>
 <87lik920h8.fsf@skywalker.in.ibm.com>
 <20120608160612.dea6d1ce.akpm@linux-foundation.org>
 <87zk8cfu3v.fsf@skywalker.in.ibm.com>
 <alpine.DEB.2.00.1206091853580.7832@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206091853580.7832@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mgorman@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, dhillf@gmail.com, aarcange@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Sat, Jun 09, 2012 at 06:55:30PM -0700, David Rientjes wrote:
> On Sat, 9 Jun 2012, Aneesh Kumar K.V wrote:
> 
> > David Rientjes didn't like HugetTLB limit to be a memcg extension and
> > wanted this to be a separate controller. I posted a v7 version that did
> > HugeTLB limit as a separate controller and used page cgroup to track
> > HugeTLB cgroup. Kamezawa Hiroyuki didn't like the usage of page_cgroup
> > in HugeTLB controller( http://mid.gmane.org/4FCD648E.90709@jp.fujitsu.com )
> > 
> 
> Yes, and thank you very much for working on v8 to remove the dependency on 
> page_cgroup and to seperate this out.  I think it will benefit users who 
> don't want to enable all of memcg but still want to account and restrict 
> hugetlb page usage, and I think the code seperation is much cleaner 
> internally.
> 

I have V9 ready to post. Only change I have against v8 is to fix the compund_order
comparison and folding the charge/uncharge patches with its users. I will wait for
your review feedback before posting V9 so that I can address the review comments
in V9. Once we get V9 out we can get the series added to -mm ?

> I'll review that patchset and suggest that the old hugetlb extension in 
> -mm be dropped in the interim.
> 

I also agree with dropping the old hugetlb extension patchset in -mm.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
