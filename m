Subject: Re: Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels
From: Ram Pai <linuxram@us.ibm.com>
In-Reply-To: <1079369109.2961.181.camel@localhost>
References: <1079130684.2961.134.camel@localhost>
	 <20040312233900.0d68711e.akpm@osdl.org> <405379ED.A7D6B1E4@us.ibm.com>
	 <20040313134842.78695cc6.akpm@osdl.org>
	 <1079369109.2961.181.camel@localhost>
Content-Type: text/plain
Message-Id: <1079379197.2844.32.camel@dyn319094bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 15 Mar 2004 11:33:17 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: maryedie@osdl.org
Cc: Andrew Morton <akpm@osdl.org>, Badari Pulavarty <pbadari@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2004-03-15 at 08:45, Mary Edie Meredith wrote:
 
> 
> 
> > And if that is indeed the case I'd be suspecting the CPU scheduler.  But
> > then, Meredith's profiles show almost completely idle CPUs.
> > 
> > The simplest way to hunt this down is the old binary-search-through-the-patches process.  But that requires some test which takes just a few minutes.
> 
> If you are referring to a binary search to find when the
> performance changed, I can do this with STP.  It may take 
> some time, but I'm willing.  I didnt want to do that if 
> the problem was a known problem.  

Based on your data, I dont think readahead patch is responsible. However
since you are seeing this only on mm kernel there is a small needle of
suspicion on the readahead patch.

How about reverting only the readahaed patch in mm tree and trying it
out? 

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc1/2.6.3-rc1-mm1/broken-out/adaptive-lazy-readahead.patch

My DSS workload benchmarks always touches the disk because I have only
4GB memory configured. I will give a try with 8GB memory and see if I
see any of your behavior. (I wont be able to put all my database in
memory)...

RP


> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
