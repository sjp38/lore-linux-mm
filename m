Date: Tue, 8 Feb 2005 20:46:48 -0500
From: Bob Picco <bob.picco@hp.com>
Subject: Re: [RFC][PATCH] no per-arch mem_map init
Message-ID: <20050209014648.GA21065@localhost.localdomain>
References: <1107891434.4716.16.camel@localhost> <20050209010452.GA20515@localhost.localdomain> <1107911850.4716.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1107911850.4716.52.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Bob Picco <bob.picco@hp.com>, lhms <lhms-devel@lists.sourceforge.net>, Jesse Barnes <jbarnes@engr.sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:	[Tue Feb 08 2005, 08:17:30PM EST]
> On Tue, 2005-02-08 at 20:04 -0500, Bob Picco wrote:
> > > -		mem_map = contig_page_data.node_mem_map = vmem_map;
> > > +		NODE_DATA(0)->node_mem_map = vmem_map;
> > This has to be changed to.
> > 		mem_map = NODE_DATA(0)->node_mem_map = vmem_map;
> > >  		free_area_init_node(0, &contig_page_data, zones_size,
> > >  				    0, zholes_size);
> > >  
> > [snip]
> > I actually submitted an identical change within my last patchset to lhms.
> 
> Good to know.  I hadn't actually noticed that bit in your patch.  It's
> another good example why to split things up into as many small, logical
> pieces as possible.  
> 
> > Not making this change requires changing use of mem_map throughout contig.c
> > and one BUG assertion in init.c.  I haven't tested this patch but it was
> > indirectly tested by me in FLATMEM configuration for lhms.
> 
> Hmm.  Do you really need the 'mem_map = ' part?  I *think*
> free_area_init_node() calls alloc_node_mem_map(), which should do that
> exact assignment for you.  
> 
> -- Dave
okay. I see what happened here.  alloc_node_mem_map is correct and makes my 
suggested change not required.  I think this was fallout from our bad composite
lhms patchset.

bob
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
