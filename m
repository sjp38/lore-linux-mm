Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id DF6EA6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:00:13 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CA8FF3EE081
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:00:11 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B38DE45DE54
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:00:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CA8845DE5F
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:00:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 89A641DB8069
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:00:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 709DE1DB805F
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:00:06 +0900 (JST)
Date: Tue, 14 Feb 2012 15:58:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH 0/6] hugetlbfs: Add cgroup resource controller for
 hugetlbfs
Message-Id: <20120214155843.42a090c2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com

On Sat, 11 Feb 2012 03:06:40 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Hi,
> 
> This patchset implements a cgroup resource controller for HugeTLB pages.
> It is similar to the existing hugetlb quota support in that the limit is
> enforced at mmap(2) time and not at fault time. HugeTLB quota limit the
> number of huge pages that can be allocated per superblock.
> 
> For shared mapping we track the region mapped by a task along with the
> hugetlb cgroup in inode region list. We keep the hugetlb cgroup charged
> even after the task that did mmap(2) exit. The uncharge happens during
> file truncate. For Private mapping we charge and uncharge from the current
> task cgroup.
> 

Hm, Could you provide an Documenation/cgroup/hugetlb.txt at RFC ?
It makes clear what your patch does.

I wonder whether this should be under memory cgroup or not. In the 1st design
of cgroup, I think it was considered one-feature-one-subsystem was good.

But in recent discussion, I tend to hear that's hard to use.
Now, memory cgroup has 

   memory.xxxxx for controlling anon/file
   memory.memsw.xxxx for controlling memory+swap
   memory.kmem.tcp_xxxx for tcp controlling.

How about memory.hugetlb.xxxxx ?


> The current patchset doesn't support cgroup hierarchy. We also don't
> allow task migration across cgroup.

What happens when a user destroys a cgroup which contains alive hugetlb pages ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
