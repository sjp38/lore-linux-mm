Date: Tue, 13 May 2008 10:05:15 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] read_barrier_depends fixlets
Message-ID: <20080513080515.GC19870@wotan.suse.de>
References: <20080505112021.GC5018@wotan.suse.de> <15818.1210087753@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15818.1210087753@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 04:29:13PM +0100, David Howells wrote:
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > While considering the impact of read_barrier_depends, it occurred to
> > me that it should really be really a noop for the compiler.
> 
> If you're defining it so, then you need to adjust memory-barriers.txt too.

_I'm_ not defining it so, it has always been defined so (code speaks
louder than words). So this document has always been wrong.i

> 
> 	========================
> 	EXPLICIT KERNEL BARRIERS
> 	========================
> 	...
> 	CPU MEMORY BARRIERS
> 	-------------------
> 
> 	The Linux kernel has eight basic CPU memory barriers:
> 
> 		TYPE		MANDATORY		SMP CONDITIONAL
> 		===============	=======================	===========================
> 		GENERAL		mb()			smp_mb()
> 		WRITE		wmb()			smp_wmb()
> 		READ		rmb()			smp_rmb()
> 		DATA DEPENDENCY	read_barrier_depends()	smp_read_barrier_depends()
> 
> 
> 	All CPU memory barriers unconditionally imply compiler barriers.
> 
> That last line needs modification, perhaps to say:
> 
> 	General, read and write memory barriers unconditionally imply general
> 	compiler barriers; data dependency barriers, however, imply a barrier
> 	only for the specific access being performed due to the fact that the
> 	instructions must be performed in a specific order.
> 
> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
