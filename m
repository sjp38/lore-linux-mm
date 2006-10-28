Date: Sat, 28 Oct 2006 16:47:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061028164726.04f89936.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061027214324.4f80e992.akpm@osdl.org>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
	<20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
	<45347288.6040808@yahoo.com.au>
	<Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
	<45360CD7.6060202@yahoo.com.au>
	<20061018123840.a67e6a44.akpm@osdl.org>
	<Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
	<20061026150938.bdf9d812.akpm@osdl.org>
	<Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	<20061027190452.6ff86cae.akpm@osdl.org>
	<Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
	<20061027192429.42bb4be4.akpm@osdl.org>
	<Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
	<20061027214324.4f80e992.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 27 Oct 2006 21:43:24 -0700
Andrew Morton <akpm@osdl.org> wrote:
> On Fri, 27 Oct 2006 19:31:20 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> > > So right now __GFP_HIGHMEM is an excellent hint telling the page allocator
> > > that it is safe to satisfy this request from removeable memory.
> > 
> > OK this works on i386 but most other platforms wont have a highmem 
> > zone.
> 
> Under this proposal platforms which wish to implement physical hot-unplug
> would need to effectively implement highmem.  They won't keep to kmap the
> pages to access their contents, but they will need to ensure that
> unreclaimable allocations be constrained to the non-removable physical
> memory.
> 
> It's all pretty simple.  But it'd be hacky to implement it in terms of
> "highmem".  It would be better if we could just tell the core MM "here's a
> 4G zone" and "here's a 60G zone".  The 60G zone is only used for
> GFP_HIGHUSER allocations and is hence unpluggable.
> 
> I don't think there's any other (practical) way of implementing hot-unplug.
> 
Thank you for mentioning to memory-unplug. I was offlined.
We (memory unplug collegues) tried dividing pgdat/zone/free_list for reclaimable
memory. but all of them were rejected ;). IMHO, using zone was the simplest one.
But hard-coded ZONE_EASYRECLAIM was not good looking..

I and Goto-san are still trying to improve sparsemem and *memory-hot-add*.
So, memory-unplug stops but is not dead project.

> But hot-unplug is just an example.  My main point here is that it is
> desirable that we get away from the up-to-four magical hard-wired zones in
> core MM.
> 
Hmm..zones should be dynamically defined at boot and configure how-to-zoning ?
or just configurable at make ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
