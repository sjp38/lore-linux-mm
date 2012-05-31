Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9C0166B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 05:44:05 -0400 (EDT)
Date: Thu, 31 May 2012 11:43:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V7 10/14] hugetlbfs: Add new HugeTLB cgroup
Message-ID: <20120531094355.GB12809@tiehlicka.suse.cz>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1338388739-22919-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120531011953.GE401@localhost.localdomain>
 <20120531054316.GD24855@skywalker.linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120531054316.GD24855@skywalker.linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu 31-05-12 11:13:16, Aneesh Kumar K.V wrote:
> On Wed, May 30, 2012 at 09:19:54PM -0400, Konrad Rzeszutek Wilk wrote:
[...]
> > > +static struct cgroup_subsys_state *hugetlb_cgroup_create(struct cgroup *cgroup)
> > > +{
> > > +	int idx;
> > > +	struct cgroup *parent_cgroup;
> > > +	struct hugetlb_cgroup *h_cgroup, *parent_h_cgroup;
> > > +
> > > +	h_cgroup = kzalloc(sizeof(*h_cgroup), GFP_KERNEL);
> > > +	if (!h_cgroup)
> > > +		return ERR_PTR(-ENOMEM);
> > > +
> > 
> > No need to check cgroup for NULL?
> 
> Other cgroups (memcg) doesn't do that. Can we really get NULL cgroup tere ?

No we cannot. See cfa449461e67b60df986170eecb089831fa9e49a

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
