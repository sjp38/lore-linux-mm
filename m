Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 4DC186B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 07:32:58 -0400 (EDT)
Date: Wed, 14 Mar 2012 04:35:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V3 5/8] hugetlbfs: Add memcg control files for
 hugetlbfs
Message-Id: <20120314043530.d6f3d424.akpm@linux-foundation.org>
In-Reply-To: <87lin38mkd.fsf@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1331622432-24683-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120313144233.49026e6a.akpm@linux-foundation.org>
	<87lin38mkd.fsf@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed, 14 Mar 2012 16:40:58 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> > 
> > > +int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx);
> > 
> > 
> > No, please put it in a header file.  Always.  Where both callers and
> > the implementation see the same propotype.
> > 
> > > +#else
> > > +static int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx)
> > > +{
> > > +	return 0;
> > > +}
> > > +#endif
> > 
> > So this will go into the same header file.
> > 
> 
> I was not sure whether i want to put mem_cgroup_hugetlb_file_init in
> linux/memcontrol.h .

The above is a declaration, not the definition (implementation).

> Ideally i want to have that in mm/hugetlb.c and in
> linux/hugetlb.h. That would require me to make mem_cgroup_read and
> others non static and move few #defines to memcontrol.h. That would
> involve larger code movement which i didn't want to do. ? What do you
> suggest ? Just move mem_cgroup_hugetlb_file_init to memcontrol.h ?

In memcontrol.h:

#ifdef CONFIG_FOO
extern int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx);
#else
static inline int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx)
{
	return 0;
}
#endif

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
