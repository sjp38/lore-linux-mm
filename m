Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 1CB8D6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 04:08:48 -0400 (EDT)
Date: Thu, 4 Apr 2013 10:08:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, x86: Do not zero hugetlbfs pages at boot. -v2
Message-ID: <20130404080845.GC29911@dhcp22.suse.cz>
References: <E1UDME8-00041J-B4@eag09.americas.sgi.com>
 <20130314085138.GA11636@dhcp22.suse.cz>
 <20130403024344.GA4384@sgi.com>
 <20130403140247.GJ16471@dhcp22.suse.cz>
 <20130403170012.GY29151@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130403170012.GY29151@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, wli@holomorphy.com

On Wed 03-04-13 12:00:12, Robin Holt wrote:
> On Wed, Apr 03, 2013 at 04:02:47PM +0200, Michal Hocko wrote:
> > On Tue 02-04-13 21:43:44, Robin Holt wrote:
> > [...]
> > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > index ca9a7c6..7683f6a 100644
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -1185,7 +1185,7 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
> > >  	while (nr_nodes) {
> > >  		void *addr;
> > >  
> > > -		addr = __alloc_bootmem_node_nopanic(
> > > +		addr = __alloc_bootmem_node_nopanic_notzeroed(
> > >  				NODE_DATA(hstate_next_node_to_alloc(h,
> > >  						&node_states[N_MEMORY])),
> > >  				huge_page_size(h), huge_page_size(h), 0);
> > 
> > Ohh, and powerpc seems to have its own opinion how to allocate huge
> > pages. See arch/powerpc/mm/hugetlbpage.c
> 
> Do I need to address their allocations?  Can I leave that part of the
> changes as something powerpc can address if they are affected by this?

I mentioned powerpc basically because I encountered it as the only
alternative implementation of alloc_bootmem_huge_page. I haven't checked
how it does the job and now that I am looking closer it uses memblock
allocator so it would need a separate fix.
I guess you are right saying that this should be handled when the need
arises.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
