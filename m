From: Christopher Lameter <cl@linux.com>
Subject: Re: [v3] mm: Add SLUB free list pointer obfuscation
Date: Thu, 27 Jul 2017 18:53:57 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707271851390.17228@nuc-kabylake>
References: <20170706002718.GA102852@beast> <cdd42a1b-ce15-df8c-6bd1-b0943275986f@linux.com> <CAGXu5jKRDhvqj0TU10W10hsdixN2P+hHzpYfSVvOFZy=hW72Mg@mail.gmail.com> <alpine.DEB.2.20.1707260906230.6341@nuc-kabylake> <CAGXu5jLkOjDKSZ48jOyh2voP17xXMeEnqzV_=8dGSvFmqdCZCA@mail.gmail.com>
 <alpine.DEB.2.20.1707261154140.9167@nuc-kabylake> <515333f5-1815-8591-503e-c0cf6941670e@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <515333f5-1815-8591-503e-c0cf6941670e@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexander Popov <alex.popov@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel->
List-Id: linux-mm.kvack.org

On Fri, 28 Jul 2017, Alexander Popov wrote:

> I don't really like ignoring double-free. I think, that:
>   - it will hide dangerous bugs in the kernel,
>   - it can make some kernel exploits more stable.
> I would rather add BUG_ON to set_freepointer() behind SLAB_FREELIST_HARDENED. Is
> it fine?

I think Kees already added some logging output.

> At the same time avoiding the consequences of some double-free errors is better
> than not doing that. It may be considered as kernel "self-healing", I don't
> know. I can prepare a second patch for do_slab_free(), as you described. Would
> you like it?

The SLUB allocator is already self healing if you enable the option to do
so on bootup (covers more than just the double free case). What you
propose here is no different than that and just another way of having
similar functionality. In the best case it would work the same way.
