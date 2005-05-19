Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4K0DkjD011934
	for <linux-mm@kvack.org>; Thu, 19 May 2005 20:13:46 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4K0Dkx6142264
	for <linux-mm@kvack.org>; Thu, 19 May 2005 20:13:46 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4K0Dk2X000887
	for <linux-mm@kvack.org>; Thu, 19 May 2005 20:13:46 -0400
Subject: Re: page flags ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <62940000.1116547401@flay>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518145644.717afc21.akpm@osdl.org>
	 <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518162302.13a13356.akpm@osdl.org> <428C6FB9.4060602@shadowen.org>
	 <20050519041116.1e3a6d29.akpm@osdl.org>
	 <1116527349.26913.1353.camel@dyn318077bld.beaverton.ibm.com>
	 <20050519155306.2b895e64.akpm@osdl.org>
	 <1116545665.26913.1378.camel@dyn318077bld.beaverton.ibm.com>
	 <62940000.1116547401@flay>
Content-Type: text/plain
Message-Id: <1116546938.26913.1386.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 19 May 2005 16:55:39 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@osdl.org>, apw@shadowen.org, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-05-19 at 17:03, Martin J. Bligh wrote:
> --On Thursday, May 19, 2005 16:34:27 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> > On Thu, 2005-05-19 at 15:53, Andrew Morton wrote:
> >> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >> > 
> >> > I am worried about the overhead this might add to kmap/kunmap().
> >> > 
> >> 
> >> kmap() already sucks.
> >> 
> > 
> > I thought so, but wanted to be explicit.
> > 
> >> >  -#define PG_highmem		 8
> >> >  +#define PG_highmem_removed	 8	/* Trying to kill this */
> >> 
> >> I thnik I'll just nuke this.
> > 
> > Yep. I was just trying to be nice - if some one gets a compile failure,
> > i wanted them to know that "we are trying to remove it, justify your
> > case".
> 
> /* #define PG_highmem		 8         Dead */ 
> 
> would work ;-)
> 
> > BTW, I tried to kill PG_slab. Other than catching error conditions
> > with memory freeing, there are few users of it
> >  
> > 	-  show_mem(): to show how much memory stuck in slab easily.
> > 	-  kobjsize()
> 
> Is really useful to be able to trace down exactly what mem is in slab,
> and otherwise were memory came from / leaked to. I spose it could could
> be a debug option, but seems a bit sad if we don't need the space yet.
> /proc/meminfo gets it from per cpu page_state, but is nice to have
> a double check.

I agree. I like that "memory stuck in slab" info too :)
Shall we wait till we really really need bits in page->flags ?
Hopefully, by then we will all be 64-bit and life would be wonderful :)

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
