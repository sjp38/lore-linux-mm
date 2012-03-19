Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 87D996B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 05:00:33 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 19 Mar 2012 14:30:29 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2J90Qhw3358948
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 14:30:26 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2JETdE7017679
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 01:29:40 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V4 09/10] memcg: move HugeTLB resource count to parent cgroup on memcg removal
In-Reply-To: <4F66A258.5060301@jp.fujitsu.com>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F66A258.5060301@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 14:30:24 +0530
Message-ID: <87r4wpj787.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Mon, 19 Mar 2012 12:04:56 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/03/17 2:39), Aneesh Kumar K.V wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > This add support for memcg removal with HugeTLB resource usage.
> > 
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> 
> 
> seems ok for now.
> 
> Now, Tejun and Costa, and I are discussing removeing -EBUSY from rmdir().
> We're now considering 'if use_hierarchy=false and parent seems full, 
> reclaim all or move charges to the root cgroup.' then -EBUSY will go away.
> 
> Is it accesptable for hugetlb ? Do you have another idea ?
> 

That should work even for hugetlb. 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
