Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 582A86B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 11:58:13 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Mar 2012 21:28:08 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2EFw54E3932308
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 21:28:05 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2ELRqZU031860
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 08:27:53 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 5/8] hugetlbfs: Add memcg control files for hugetlbfs
In-Reply-To: <20120314043530.d6f3d424.akpm@linux-foundation.org>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120313144233.49026e6a.akpm@linux-foundation.org> <87lin38mkd.fsf@linux.vnet.ibm.com> <20120314043530.d6f3d424.akpm@linux-foundation.org>
Date: Wed, 14 Mar 2012 21:27:57 +0530
Message-ID: <87d38f89a2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed, 14 Mar 2012 04:35:30 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 14 Mar 2012 16:40:58 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > > 
> > > > +int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx);
> > > 
> > > 
> > > No, please put it in a header file.  Always.  Where both callers and
> > > the implementation see the same propotype.
> > > 
> > > > +#else
> > > > +static int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx)
> > > > +{
> > > > +	return 0;
> > > > +}
> > > > +#endif
> > > 
> > > So this will go into the same header file.
> > > 
> > 
> > I was not sure whether i want to put mem_cgroup_hugetlb_file_init in
> > linux/memcontrol.h .
> 
> The above is a declaration, not the definition (implementation).
> 
> > Ideally i want to have that in mm/hugetlb.c and in
> > linux/hugetlb.h. That would require me to make mem_cgroup_read and
> > others non static and move few #defines to memcontrol.h. That would
> > involve larger code movement which i didn't want to do. ? What do you
> > suggest ? Just move mem_cgroup_hugetlb_file_init to memcontrol.h ?
> 
> In memcontrol.h:
> 
> #ifdef CONFIG_FOO
> extern int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx);
> #else
> static inline int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx)
> {
> 	return 0;
> }
> #endif
> 

Will do that in the next iteration.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
