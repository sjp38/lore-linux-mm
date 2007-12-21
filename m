Date: Fri, 21 Dec 2007 13:37:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB
In-Reply-To: <476BF0E3.8010201@hp.com>
Message-ID: <Pine.LNX.4.64.0712211335270.3795@schroedinger.engr.sgi.com>
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com>
 <476BF0E3.8010201@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Seger <Mark.Seger@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Dec 2007, Mark Seger wrote:

> Sorry for being confused, but I thought that a slab was made up of a number of
> objects and above you're saying slab_size is the size of single object.
> Furthermore, looking at /sys/slab/shmem_inode_cache I see:
> 
> object_size = 960
> objs_per_slab = 4
> 
> which implies a slab is made up more than one object, so which is it?  could
> it be a simple matter of clearer names?  I also see

Yes a slab holds "objs_per_slab" object/
> 
> slab_size = 968
> 
> which certainly supports your statement about this being the size of an object
> and it looks like there is 8 bytes of overhead.  finally, I also see
> 
> objects = 242
> 
> and objects * obj_per_slab = slabsize.  is that a coincidence?

This means that the slab contains 242 active objects. From the "slabs" 
field you can deduce how many objects the slab could hold:

slabs * objs_per_slab

If you subtract "objects" from this then you have the number of unused 
objects in the slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
