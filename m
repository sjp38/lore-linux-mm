Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id E5CE46B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 00:40:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 24 May 2012 10:10:08 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4O4e5UB10355052
	for <linux-mm@kvack.org>; Thu, 24 May 2012 10:10:06 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4OA9hA0010299
	for <linux-mm@kvack.org>; Thu, 24 May 2012 15:39:43 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg/hugetlb: Add failcnt support for hugetlb extension
In-Reply-To: <20120523161750.f0e22c5b.akpm@linux-foundation.org>
References: <1337686991-26418-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120523161750.f0e22c5b.akpm@linux-foundation.org>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Thu, 24 May 2012 10:10:00 +0530
Message-ID: <87likiyyxr.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue, 22 May 2012 17:13:11 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> Expose the failcnt details to userspace similar to memory and memsw.
>
> Why?
>

to help us find whether there was an allocation failure due to HugeTLB
limit. 

> In general, it is best not to add any new userspace interfaces at all. 
> We will do so, if there are good reasons.  But you've provided no reason
> at all.
>
>>  include/linux/hugetlb.h |    2 +-
>>  mm/memcontrol.c         |   40 ++++++++++++++++++++++++++--------------
>
> Documentation/cgroups/memory.txt needs updating also.  You modify the
> user insterface, you modify documentation - this should be automatic
> for all of us.

How about the below

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 730e222a..3a47ec5 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -80,6 +80,7 @@ Brief summary of control files.
  memory.hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
  memory.hugetlb.<hugepagesize>.usage_in_bytes     # show current res_counter usage for "hugepagesize" hugetlb
 						  # see 5.7 for details
+ memory.hugetlb.<hugepagesize>.failcnt		  # show the number of allocation failure due to HugeTLB limit
 
 1. History
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
