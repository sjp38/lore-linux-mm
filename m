Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 589856B0062
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 21:03:44 -0500 (EST)
Message-ID: <1355364222.9244.3.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: add node physical memory range to sysfs
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Wed, 12 Dec 2012 18:03:42 -0800
In-Reply-To: <50C933E9.2040707@linux.vnet.ibm.com>
References: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net>
	 <20121207155125.d3117244.akpm@linux-foundation.org>
	 <50C28720.3070205@linux.vnet.ibm.com>
	 <1355361524.5255.9.camel@buesod1.americas.hpqcorp.net>
	 <50C933E9.2040707@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2012-12-12 at 17:48 -0800, Dave Hansen wrote:
> On 12/12/2012 05:18 PM, Davidlohr Bueso wrote:
> > On Fri, 2012-12-07 at 16:17 -0800, Dave Hansen wrote:
> >> Seems like the better way to do this would be to expose the DIMMs
> >> themselves in some way, and then map _those_ back to a node.
> > 
> > Good point, and from a DIMM perspective, I agree, and will look into
> > this. However, IMHO, having the range of physical addresses for every
> > node still provides valuable information, from a NUMA point of view. For
> > example, dealing with node related e820 mappings.
> 
> But if we went and did it per-DIMM (showing which physical addresses and
> NUMA nodes a DIMM maps to), wouldn't that be redundant with this
> proposed interface?
> 

If DIMMs overlap between nodes, then we wouldn't have an exact range for
a node in question. Having both approaches would complement each other.

> How do you plan to use this in practice, btw?
> 

It started because I needed to recognize the address of a node to remove
it from the e820 mappings and have the system "ignore" the node's
memory.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
