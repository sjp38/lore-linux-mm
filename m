Date: Tue, 29 Apr 2008 11:49:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [2/2] vmallocinfo: Add caller information
In-Reply-To: <20080428124849.4959c419@infradead.org>
Message-ID: <Pine.LNX.4.64.0804291143080.12128@schroedinger.engr.sgi.com>
References: <20080318222701.788442216@sgi.com> <20080318222827.519656153@sgi.com>
 <20080429084854.GA14913@elte.hu> <Pine.LNX.4.64.0804291001420.10847@schroedinger.engr.sgi.com>
 <20080428124849.4959c419@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Apr 2008, Arjan van de Ven wrote:

> > Sorry lost track of this issue. Adding stracktrace support is not a 
> > trivial thing and will change the basic handling of vmallocinfo.
> > 
> > Not sure if stacktrace support can be enabled without a penalty on
> > various platforms. Doesnt this require stackframes to be formatted in
> > a certain way?
> 
> it doesn't.

Hmmm... Why do we have CONFIG_FRAMEPOINTER then?

The current implementation of vmalloc_caller() follows what we have done 
with kmalloc_track_caller. Its low overhead and always on.

It would be great if we could have stacktrace support both for kmalloc and 
vmalloc in the same way also with low overhead but I think following a 
backtrace requires much more than simply storing the caller address. A 
mechanism like that would require an explicit kernel CONFIG option. A 
year or so ago we had patches to implement stacktraces in the slab 
allocators but they were not merged due to various arch specific issues 
with backtraces.

We could dump the offending x86_64 pieces. Some detail of what
/proc/vmallocinfo would be lost then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
