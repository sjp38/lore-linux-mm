Date: Mon, 28 Apr 2008 14:00:26 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [2/2] vmallocinfo: Add caller information
Message-ID: <20080428140026.32aaf3bf@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0804291143080.12128@schroedinger.engr.sgi.com>
References: <20080318222701.788442216@sgi.com>
	<20080318222827.519656153@sgi.com>
	<20080429084854.GA14913@elte.hu>
	<Pine.LNX.4.64.0804291001420.10847@schroedinger.engr.sgi.com>
	<20080428124849.4959c419@infradead.org>
	<Pine.LNX.4.64.0804291143080.12128@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2008 11:49:54 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 28 Apr 2008, Arjan van de Ven wrote:
> 
> > > Sorry lost track of this issue. Adding stracktrace support is not
> > > a trivial thing and will change the basic handling of vmallocinfo.
> > > 
> > > Not sure if stacktrace support can be enabled without a penalty on
> > > various platforms. Doesnt this require stackframes to be
> > > formatted in a certain way?
> > 
> > it doesn't.
> 
> Hmmm... Why do we have CONFIG_FRAMEPOINTER then?

to make the backtraces more accurate.


> The current implementation of vmalloc_caller() follows what we have
> done with kmalloc_track_caller. Its low overhead and always on.

stacktraces aren't entirely free, the cost is O(nr of modules) unfortunately ;(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
