Date: Wed, 24 May 2006 13:32:53 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [5/5] move_pages: 32bit support (i386,x86_64 and ia64)
Message-Id: <20060524133253.23fe19a2.akpm@osdl.org>
In-Reply-To: <20060523174410.10156.43268.sendpatchset@schroedinger.engr.sgi.com>
References: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
	<20060523174410.10156.43268.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Jens Axboe <axboe@suse.de>
Cc: hugh@veritas.com, linux-ia64@vger.kernel.org, a.p.zijlstra@chello.nl, lee.schermerhorn@hp.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> sys_move_pages() support for 32bit (i386 plus ia64 and x86_64 compat layers)
> 
> Add support for move_pages() on i386 and also add the
> compat functions necessary to run 32 bit binaries on x86_64 and ia64.
> 
> Add compat_sys_move_pages to both the x86_64 and the ia64 32bit binary
> layer. Note that both are not up to date so I added the missing pieces.
> Not sure if this is done the right way.
> 
> This probably needs some fixups:
> 
> 1. What about sys_vmsplice on x86_64?
> 
> 2. There is a whole range of syscalls missing for ia64 that I basically
>    interpolated from elsewhere.

I dropped the ia64 bits - looks like that's all on death row anyway.

The omission of sys_vmsplice() from the x86 syscall table does appear to
be, umm, a glaring omission.  Jens, what's up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
