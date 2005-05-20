Date: Thu, 19 May 2005 17:20:10 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: page flags ?
Message-ID: <66070000.1116548410@flay>
In-Reply-To: <1116546938.26913.1386.camel@dyn318077bld.beaverton.ibm.com>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com> <20050518145644.717afc21.akpm@osdl.org> <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com> <20050518162302.13a13356.akpm@osdl.org> <428C6FB9.4060602@shadowen.org> <20050519041116.1e3a6d29.akpm@osdl.org> <1116527349.26913.1353.camel@dyn318077bld.beaverton.ibm.com> <20050519155306.2b895e64.akpm@osdl.org> <1116545665.26913.1378.camel@dyn318077bld.beaverton.ibm.com> <62940000.1116547401@flay> <1116546938.26913.1386.camel@dyn318077bld.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, apw@shadowen.org, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>> > BTW, I tried to kill PG_slab. Other than catching error conditions
>> > with memory freeing, there are few users of it
>> >  
>> > 	-  show_mem(): to show how much memory stuck in slab easily.
>> > 	-  kobjsize()
>> 
>> Is really useful to be able to trace down exactly what mem is in slab,
>> and otherwise were memory came from / leaked to. I spose it could could
>> be a debug option, but seems a bit sad if we don't need the space yet.
>> /proc/meminfo gets it from per cpu page_state, but is nice to have
>> a double check.
> 
> I agree. I like that "memory stuck in slab" info too :)
> Shall we wait till we really really need bits in page->flags ?
> Hopefully, by then we will all be 64-bit and life would be wonderful :)

Would be nicer not to kill them until we need ... perhaps they could be
commented as to their potential demise? Then the debug ones could be
wrapped in something else, at least, and made available on 64 bit only
(when it comes to that ...)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
