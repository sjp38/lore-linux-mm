Date: Tue, 29 Apr 2008 21:29:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [2/2] vmallocinfo: Add caller information
Message-ID: <20080429192913.GA18279@elte.hu>
References: <20080318222701.788442216@sgi.com> <20080318222827.519656153@sgi.com> <20080429084854.GA14913@elte.hu> <Pine.LNX.4.64.0804291001420.10847@schroedinger.engr.sgi.com> <20080428124849.4959c419@infradead.org> <Pine.LNX.4.64.0804291143080.12128@schroedinger.engr.sgi.com> <20080428140026.32aaf3bf@infradead.org> <Pine.LNX.4.64.0804291204450.12689@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804291204450.12689@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 28 Apr 2008, Arjan van de Ven wrote:
> 
> > > Hmmm... Why do we have CONFIG_FRAMEPOINTER then?
> > 
> > to make the backtraces more accurate.
> 
> Well so we display out of whack backtraces? There are also issues on 
> platforms that do not have a stack in the classic sense (rotating 
> register file on IA64 and Sparc64 f.e.). Determining a backtrace can 
> be very expensive.

they have to solve that for kernel oopses and for lockdep somehow 
anyway. Other users of stacktrace are: fault injection, kmemcheck, 
latencytop, ftrace. All new debugging and instrumentation code uses it, 
and for a good reason.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
