Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id E74D96B00ED
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 03:14:32 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 19 Mar 2012 08:04:45 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2J7EHFT929826
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 18:14:17 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2J7EGWG025142
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 18:14:17 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V4 07/10] hugetlbfs: Add memcg control files for hugetlbfs
In-Reply-To: <4F66A059.20801@jp.fujitsu.com>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F66A059.20801@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 12:44:11 +0530
Message-ID: <87wr6hjc58.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Mon, 19 Mar 2012 11:56:25 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/03/17 2:39), Aneesh Kumar K.V wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > This add control files for hugetlbfs in memcg
> > 
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> 
> 
> I have a question. When a user does
> 
> 	1. create memory cgroup as
> 		/cgroup/A
> 	2. insmod hugetlb.ko
> 	3. ls /cgroup/A
> 
> and then, files can be shown ? Don't we have any problem at rmdir A ?
> 
> I'm sorry if hugetlb never be used as module.

HUGETLBFS cannot be build as kernel module


> 
> a comment below.
> 
> > ---
> >  include/linux/hugetlb.h    |   17 +++++++++++++++
> >  include/linux/memcontrol.h |    7 ++++++
> >  mm/hugetlb.c               |   25 ++++++++++++++++++++++-
> >  mm/memcontrol.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 96 insertions(+), 1 deletions(-)


......

> > 
> > +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> > +static char *mem_fmt(char *buf, unsigned long n)
> > +{
> > +	if (n >= (1UL << 30))
> > +		sprintf(buf, "%luGB", n >> 30);
> > +	else if (n >= (1UL << 20))
> > +		sprintf(buf, "%luMB", n >> 20);
> > +	else
> > +		sprintf(buf, "%luKB", n >> 10);
> > +	return buf;
> > +}
> > +
> > +int mem_cgroup_hugetlb_file_init(int idx)
> > +{
> 
> 
> __init ? 

Added .

>And... do we have guarantee that this function is called before
> creating root mem cgroup even if CONFIG_HUGETLBFS=y ?
> 

Yes. This should be called before creating root mem cgroup.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
