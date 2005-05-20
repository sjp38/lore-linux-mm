Date: Thu, 19 May 2005 17:03:21 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: page flags ?
Message-ID: <62940000.1116547401@flay>
In-Reply-To: <1116545665.26913.1378.camel@dyn318077bld.beaverton.ibm.com>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com> <20050518145644.717afc21.akpm@osdl.org> <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com> <20050518162302.13a13356.akpm@osdl.org> <428C6FB9.4060602@shadowen.org> <20050519041116.1e3a6d29.akpm@osdl.org> <1116527349.26913.1353.camel@dyn318077bld.beaverton.ibm.com> <20050519155306.2b895e64.akpm@osdl.org> <1116545665.26913.1378.camel@dyn318077bld.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@osdl.org>
Cc: apw@shadowen.org, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--On Thursday, May 19, 2005 16:34:27 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:

> On Thu, 2005-05-19 at 15:53, Andrew Morton wrote:
>> Badari Pulavarty <pbadari@us.ibm.com> wrote:
>> > 
>> > I am worried about the overhead this might add to kmap/kunmap().
>> > 
>> 
>> kmap() already sucks.
>> 
> 
> I thought so, but wanted to be explicit.
> 
>> >  -#define PG_highmem		 8
>> >  +#define PG_highmem_removed	 8	/* Trying to kill this */
>> 
>> I thnik I'll just nuke this.
> 
> Yep. I was just trying to be nice - if some one gets a compile failure,
> i wanted them to know that "we are trying to remove it, justify your
> case".

/* #define PG_highmem		 8         Dead */ 

would work ;-)

> BTW, I tried to kill PG_slab. Other than catching error conditions
> with memory freeing, there are few users of it
>  
> 	-  show_mem(): to show how much memory stuck in slab easily.
> 	-  kobjsize()

Is really useful to be able to trace down exactly what mem is in slab,
and otherwise were memory came from / leaked to. I spose it could could
be a debug option, but seems a bit sad if we don't need the space yet.
/proc/meminfo gets it from per cpu page_state, but is nice to have
a double check.

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
