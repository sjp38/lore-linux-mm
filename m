Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 184F96B0044
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 01:35:03 -0500 (EST)
Date: Mon, 26 Jan 2009 22:33:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
Message-Id: <20090126223350.610b0283.akpm@linux-foundation.org>
In-Reply-To: <20090119175919.GA7476@us.ibm.com>
References: <4973AEEC.70504@gmail.com>
	<20090119175919.GA7476@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gary Hade <garyhade@us.ibm.com>
Cc: Roel Kluin <roel.kluin@gmail.com>, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jan 2009 09:59:19 -0800 Gary Hade <garyhade@us.ibm.com> wrote:

> On Sun, Jan 18, 2009 at 11:36:28PM +0100, Roel Kluin wrote:
> > get_nid_for_pfn() returns int
> > 
> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > ---
> > vi drivers/base/node.c +256
> > static int get_nid_for_pfn(unsigned long pfn)
> > 
> > diff --git a/drivers/base/node.c b/drivers/base/node.c
> > index 43fa90b..f8f578a 100644
> > --- a/drivers/base/node.c
> > +++ b/drivers/base/node.c
> > @@ -303,7 +303,7 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
> >  	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
> >  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> >  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> > -		unsigned int nid;
> > +		int nid;
> > 
> >  		nid = get_nid_for_pfn(pfn);
> >  		if (nid < 0)
> 
> My mistake.  Good catch.
> 

Presumably the (nid < 0) case has never happened.

Should we retain the test?

Is silently skipping the node in that case desirable behaviour?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
