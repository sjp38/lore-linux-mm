Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id C9B686B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 06:47:03 -0400 (EDT)
Date: Fri, 30 Mar 2012 12:46:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V4 05/10] hugetlb: add charge/uncharge calls for HugeTLB
 alloc/free
Message-ID: <20120330104650.GB15375@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1331919570-2264-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120328131706.GF20949@tiehlicka.suse.cz>
 <87sjgs1v6x.fsf@skywalker.in.ibm.com>
 <20120329081003.GC30465@tiehlicka.suse.cz>
 <871uoamkxr.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871uoamkxr.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Fri 30-03-12 16:10:00, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Wed 28-03-12 23:09:34, Aneesh Kumar K.V wrote:
> >> Michal Hocko <mhocko@suse.cz> writes:
> >> 
> >> > On Fri 16-03-12 23:09:25, Aneesh Kumar K.V wrote:
> >> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >> >> 
> >> >> This adds necessary charge/uncharge calls in the HugeTLB code
> >> >
> >> > This begs for more description...
> >> > Other than that it looks correct.
> >> >
> >> 
> >> Updated as below
> >> 
> >>     hugetlb: add charge/uncharge calls for HugeTLB alloc/free
> >>     
> >>     This adds necessary charge/uncharge calls in the HugeTLB code. We do
> >>     memcg charge in page alloc and uncharge in compound page destructor.
> >>     We also need to ignore HugeTLB pages in __mem_cgroup_uncharge_common
> >>     because that get called from delete_from_page_cache
> >
> > and from mem_cgroup_end_migration used during soft_offline_page.
> >
> > Btw., while looking at mem_cgroup_end_migration, I have noticed that you
> > need to take care of mem_cgroup_prepare_migration as well otherwise the
> > page would get charged as a normal (shmem) page.
> >
> 
> Won't we skip HugeTLB pages in migrate ?

Yes but we still migrate for memory failure (see soft_offline_page).

> check_range do check for is_vm_hugetlb_page.
> 
> -aneesh
> 

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
