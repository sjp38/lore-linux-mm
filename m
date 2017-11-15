Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F0DF26B0275
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 17:50:20 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p9so25221824pgc.6
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 14:50:20 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id n17si1526050pgv.72.2017.11.15.14.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 14:50:20 -0800 (PST)
Date: Wed, 15 Nov 2017 22:49:50 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-ID: <20171115224941.GA4286@castle>
References: <20171114125026.7055-1-guro@fb.com>
 <20171114131736.v2m6alrt5gelmh5c@dhcp22.suse.cz>
 <alpine.DEB.2.10.1711141425220.112995@chino.kir.corp.google.com>
 <20171115081818.ucnp26tho4qffdwx@dhcp22.suse.cz>
 <alpine.DEB.2.10.1711151443090.103372@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1711151443090.103372@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, Nov 15, 2017 at 02:46:00PM -0800, David Rientjes wrote:
> On Wed, 15 Nov 2017, Michal Hocko wrote:
> 
> > > > >  	if (!hugepages_supported())
> > > > >  		return;
> > > > >  	seq_printf(m,
> > > > > @@ -2987,6 +2989,11 @@ void hugetlb_report_meminfo(struct seq_file *m)
> > > > >  			h->resv_huge_pages,
> > > > >  			h->surplus_huge_pages,
> > > > >  			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> > > > > +
> > > > > +	for_each_hstate(h)
> > > > > +		total += (PAGE_SIZE << huge_page_order(h)) * h->nr_huge_pages;
> > > > 
> > > > Please keep the total calculation consistent with what we have there
> > > > already.
> > > > 
> > > 
> > > Yeah, and I'm not sure if your comment eludes to this being racy, but it 
> > > would be better to store the default size for default_hstate during the 
> > > iteration to total the size for all hstates.
> > 
> > I just meant to have the code consistent. I do not prefer one or other
> > option.
> 
> It's always nice when HugePages_Total * Hugepagesize cannot become greater 
> than Hugetlb.  Roman, could you factor something like this into your 
> change accompanied with a documentation upodate as suggested by Dave?

Hi David!

Working on it... I'll post an update soon.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
