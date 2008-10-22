Date: Wed, 22 Oct 2008 11:20:24 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC v7][PATCH 0/9] Kernel based checkpoint/restart
Message-ID: <20081022092024.GC12453@elte.hu>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu> <20081021122135.4bce362c.akpm@linux-foundation.org> <1224621667.1848.228.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1224621667.1848.228.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oren Laadan <orenl@cs.columbia.edu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

* Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Tue, 2008-10-21 at 12:21 -0700, Andrew Morton wrote:
> > On Mon, 20 Oct 2008 01:40:28 -0400
> > Oren Laadan <orenl@cs.columbia.edu> wrote:
> > > These patches implement basic checkpoint-restart [CR]. This version
> > > (v7) supports basic tasks with simple private memory, and open files
> > > (regular files and directories only).
> > 
> > - how useful is this code as it stands in real-world usage?
> 
> Right now, an application must be specifically written to use these 
> mew system calls.  It must be a single process and not share any 
> resources with other processes.  The only file descriptors that may be 
> open are simple files and may not include sockets or pipes.
> 
> What this means in practice is that it is useful for a simple app 
> doing computational work.

say a chemistry application doing calculations. Or a raytracer with a 
large job. Both can take many hours (days!) even on very fast machine 
and the restrictions on rebootability can hurt in such cases.

You should reach a minimal level of initial practical utility: say some 
helper tool that allows testers to checkpoint and restore a real PovRay 
session - without any modification to a stock distro PovRay.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
