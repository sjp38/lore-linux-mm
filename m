Date: Wed, 25 Aug 2004 00:20:26 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
    16gb
In-Reply-To: <20040824144312.09b4af42.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0408242352470.2713-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: kmannth@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2004, Andrew Morton wrote:
> bugme-daemon@osdl.org wrote:
> >
> > http://bugme.osdl.org/show_bug.cgi?id=3268
> > 
> >            Summary: Lowmemory exhaustion problem with v2.6.8.1-mm4 16gb
> > Problem Description:  I run out of lowmemory very easily using /dev/shm/
> > I have 64g and Numa/Discontig enabled in my kernel.  
> > 
> > Steps to reproduce:  Fill up 1/2 or more of /dev/shm (on my system it is about
> > 1/3-1/2 of my total system memory) with lots of kernel builds.  Observe system
> > breakdown.  (If you want the script I will email it to you).  I have seen this
> > with both 32 gigs and 16 gigs...
> 
> I assume this is because we're using up all of lowmem with filesystem metadata.
> 
> Hugh?

Probably, though it's not something anyone reported before.

Filesystem metadata being, not tmpfs's indirect blocks (which use highmem),
but the plenitude of inodes and dentries: which would get pruned if it were
a disk-based filesystem, but cannot because this one is all in memory.

I've not done the arithmetic... tomorrow.  I'll try to reproduce something
similar (I don't have 16GB and I don't have NUMA, though latter probably
not relevant) tomorrow, and fix (decide default nr_inodes by lowmem).

Keith, please do mail me your script (in case there's something special
in there e.g. will make a difference if your sources are linked or not),
and also your /proc/slabinfo near OOMing, if that's convenient.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
