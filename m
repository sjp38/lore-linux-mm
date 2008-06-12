Date: Thu, 12 Jun 2008 01:02:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: repeatable slab corruption with LTP msgctl08
Message-Id: <20080612010200.106df621.akpm@linux-foundation.org>
In-Reply-To: <20080611233449.08e6eaa0.akpm@linux-foundation.org>
References: <20080611221324.42270ef2.akpm@linux-foundation.org>
	<20080611233449.08e6eaa0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>, Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 23:34:49 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 11 Jun 2008 22:13:24 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Running current mainline on my old 2-way PIII.  Distro is RH FC1.  LTP
> > version is ltp-full-20070228 (lots of retro-computing there).
> > 
> > Config is at http://userweb.kernel.org/~akpm/config-vmm.txt
> > 
> > 
> > ./testcases/bin/msgctl08 crashes after ten minutes or so:
> 
> ah, it runs to completion in about ten seconds on 2.6.25, so it'll be
> easy for someone to bisect it.
> 
> What's that?  Sigh.  OK.  I wasn't doing anything much anyway.

Oh drat.  git-bisect tells me that this one-year-old msgctl08's
execution time vastly increased when we added

commit f7bf3df8be72d98afa84f5ff183e14c1ba1e560d
Author: Nadia Derbey <Nadia.Derbey@bull.net>
Date:   Tue Apr 29 01:00:39 2008 -0700

    ipc: scale msgmni to the amount of lowmem
    

But we already knew that, and LTP got changed to fix it.

So I was wrong in assuming that the long-execution-time correlates with
the slab-corruption bug.

And the slab corruption bug takes half an hour to reproduce and an
unknown amount of time to not-reproduce.  I don't think I'll be able to
complete this before I disappear for over a week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
