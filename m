Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id C6B536B13F0
	for <linux-mm@kvack.org>; Sun, 12 Feb 2012 12:44:33 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 12 Feb 2012 17:42:14 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1CHdBoR3031208
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 04:39:13 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1CHiIkP000495
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 04:44:18 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/6] hugetlbfs: Add cgroup resource controller for hugetlbfs
In-Reply-To: <CAJd=RBCRG1oXV6jjxxatXEpk5MipL-PyapSoYFMEhK-==YOVaw@mail.gmail.com>
References: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <CAJd=RBCRG1oXV6jjxxatXEpk5MipL-PyapSoYFMEhK-==YOVaw@mail.gmail.com>
Date: Sun, 12 Feb 2012 23:14:02 +0530
Message-ID: <87y5s8x7z1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

On Sat, 11 Feb 2012 20:37:23 +0800, Hillf Danton <dhillf@gmail.com> wrote:
> On Sat, Feb 11, 2012 at 5:36 AM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > Hi,
> >
> > This patchset implements a cgroup resource controller for HugeTLB pages.
> > It is similar to the existing hugetlb quota support in that the limit is
> > enforced at mmap(2) time and not at fault time. HugeTLB quota limit the
> > number of huge pages that can be allocated per superblock.
> >
> 
> Hello Aneesh
> 
> Thanks for your work:)
> 
> Mind to post the whole patchset on LKML with Andrea, Michal,
> Johannes and Andrew also Cced, for more eyes and thoughts?
> 

Will do in the next iteration 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
