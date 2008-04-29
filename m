Date: Tue, 29 Apr 2008 12:09:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [2/2] vmallocinfo: Add caller information
In-Reply-To: <20080428140026.32aaf3bf@infradead.org>
Message-ID: <Pine.LNX.4.64.0804291204450.12689@schroedinger.engr.sgi.com>
References: <20080318222701.788442216@sgi.com> <20080318222827.519656153@sgi.com>
 <20080429084854.GA14913@elte.hu> <Pine.LNX.4.64.0804291001420.10847@schroedinger.engr.sgi.com>
 <20080428124849.4959c419@infradead.org> <Pine.LNX.4.64.0804291143080.12128@schroedinger.engr.sgi.com>
 <20080428140026.32aaf3bf@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Apr 2008, Arjan van de Ven wrote:

> > Hmmm... Why do we have CONFIG_FRAMEPOINTER then?
> 
> to make the backtraces more accurate.

Well so we display out of whack backtraces? There are also issues on 
platforms that do not have a stack in the classic sense (rotating register 
file on IA64 and Sparc64 f.e.). Determining a backtrace can be very 
expensive.

> > The current implementation of vmalloc_caller() follows what we have
> > done with kmalloc_track_caller. Its low overhead and always on.
> 
> stacktraces aren't entirely free, the cost is O(nr of modules) unfortunately ;(

The current implementation /proc/vmallocinfo avoids these issues and 
with just one caller address it can print one line per vmalloc request. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
