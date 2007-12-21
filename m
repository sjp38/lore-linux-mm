Date: Fri, 21 Dec 2007 13:32:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB
In-Reply-To: <476AFC6C.3080903@hp.com>
Message-ID: <Pine.LNX.4.64.0712211330350.3795@schroedinger.engr.sgi.com>
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com>
 <476AFC6C.3080903@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Seger <Mark.Seger@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Dec 2007, Mark Seger wrote:

> What I'm not sure about is how this maps to the old slab info.  Specifically,
> I believe in the old model one reported on the size taken up by the slabs
> (number of slabs X number of objects/slab X object size).  There was a second
> size for the actual number of objects in use, so in my report that looked like
> this:
> 
> #                      <-----------Objects----------><---------Slab
> Allocation------>
> #Name                  InUse   Bytes   Alloc   Bytes   InUse   Bytes   Total
> Bytes
> nfs_direct_cache           0       0       0       0       0       0       0
> 0
> nfs_write_data            36   27648      40   30720       8   32768       8
> 32768
> 
> the slab allocation was real memory allocated (which should come close to
> Slab: in /proc/meminfo, right?) for the slabs while the object bytes were

The real memory allocates can be deducated from the "slabs" field. 
Multiply that by the order of the slab and you have the size of it.

The "objects" are the actual objects in current use.

> To get back to my original question, I'd like to make sure that I'm reporting
> useful information and not just data for the sake of it.  In one of your
> postings I saw a report you had that showed:
> 
> slubinfo - version: 1.0
> # name            <objects> <order> <objsize> <slabs>/<partial>/<cpu> <flags>
> <nodes>

That report can be had using the slabinfo tool. See 
Documentation/vm/slabinfo.c

> How useful is order, cpu, flags and nodes?
> Do people really care about how much memory is taken up by objects vs slabs?
> If not, I could see reporting for each slab:
> - object size
> - number objects
> - slab size
> - number of slabs
> - total memory (slab size X number of slabs)
> - whatever else people might think to be useful such as order, cpu, flags, etc

Sounds fine.
 
> Another thing I noticed is a number of the slabs are simply links to the same
> base name and is it sufficient to just report the base names and not those
> linked to it?  Seems reasonable to me...

slabinfo reports it like that.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
