Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5E6406B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 03:16:39 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:16:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V9 04/15] hugetlb: use mmu_gather instead of a temporary
 linked list for accumulating pages
Message-ID: <20120614071637.GB27397@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339583254-895-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120613145923.GA14777@tiehlicka.suse.cz>
 <871uljnp71.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871uljnp71.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 13-06-12 22:07:06, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Wed 13-06-12 15:57:23, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >> 
> >> Use a mmu_gather instead of a temporary linked list for accumulating
> >> pages when we unmap a hugepage range
> >
> > Sorry for coming up with the comment that late but you owe us an
> > explanation _why_ you are doing this.
> >
> > I assume that this fixes a real problem when we take i_mmap_mutex
> > already up in 
> > unmap_mapping_range
> >   mutex_lock(&mapping->i_mmap_mutex);
> >   unmap_mapping_range_tree | unmap_mapping_range_list 
> >     unmap_mapping_range_vma
> >       zap_page_range_single
> >         unmap_single_vma
> > 	  unmap_hugepage_range
> > 	    mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
> >
> > And that this should have been marked for stable as well (I haven't
> > checked when this has been introduced).
> 
> Switch to mmu_gather is to get rid of the use of page->lru so that i can use it for
> active list.

So can we get this to the changelog please?

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
