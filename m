Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j191Ham4007085
	for <linux-mm@kvack.org>; Tue, 8 Feb 2005 20:17:36 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j191HZ5U189940
	for <linux-mm@kvack.org>; Tue, 8 Feb 2005 20:17:35 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j191HZlq010631
	for <linux-mm@kvack.org>; Tue, 8 Feb 2005 20:17:35 -0500
Subject: Re: [RFC][PATCH] no per-arch mem_map init
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050209010452.GA20515@localhost.localdomain>
References: <1107891434.4716.16.camel@localhost>
	 <20050209010452.GA20515@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 08 Feb 2005 17:17:30 -0800
Message-Id: <1107911850.4716.52.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Jesse Barnes <jbarnes@engr.sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-02-08 at 20:04 -0500, Bob Picco wrote:
> > -		mem_map = contig_page_data.node_mem_map = vmem_map;
> > +		NODE_DATA(0)->node_mem_map = vmem_map;
> This has to be changed to.
> 		mem_map = NODE_DATA(0)->node_mem_map = vmem_map;
> >  		free_area_init_node(0, &contig_page_data, zones_size,
> >  				    0, zholes_size);
> >  
> [snip]
> I actually submitted an identical change within my last patchset to lhms.

Good to know.  I hadn't actually noticed that bit in your patch.  It's
another good example why to split things up into as many small, logical
pieces as possible.  

> Not making this change requires changing use of mem_map throughout contig.c
> and one BUG assertion in init.c.  I haven't tested this patch but it was
> indirectly tested by me in FLATMEM configuration for lhms.

Hmm.  Do you really need the 'mem_map = ' part?  I *think*
free_area_init_node() calls alloc_node_mem_map(), which should do that
exact assignment for you.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
