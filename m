From: Christopher Lameter <cl@linux.com>
Subject: Re: [v3] mm: Add SLUB free list pointer obfuscation
Date: Thu, 27 Jul 2017 10:15:26 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707271014510.15182@nuc-kabylake>
References: <20170706002718.GA102852@beast> <cdd42a1b-ce15-df8c-6bd1-b0943275986f@linux.com> <CAGXu5jKRDhvqj0TU10W10hsdixN2P+hHzpYfSVvOFZy=hW72Mg@mail.gmail.com> <alpine.DEB.2.20.1707260906230.6341@nuc-kabylake> <CAGXu5jLkOjDKSZ48jOyh2voP17xXMeEnqzV_=8dGSvFmqdCZCA@mail.gmail.com>
 <alpine.DEB.2.20.1707261154140.9167@nuc-kabylake> <CAGXu5jLNeO-WmaQXp9z-+iw2sha-DXixtQ-fjQmahUkh0Hvxeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jLNeO-WmaQXp9z-+iw2sha-DXixtQ-fjQmahUkh0Hvxeg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Popov <alex.popov@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>"kernel-hardening@lists.openwall.com" <ke>
List-Id: linux-mm.kvack.org

On Wed, 26 Jul 2017, Kees Cook wrote:

> > Although in either case we are adding code to the fastpath...
>
> While I'd like it unconditionally, I think Alexander's proposal was to
> put it behind CONFIG_SLAB_FREELIST_HARDENED.

Sounds good.

> BTW, while I've got your attention, can you Ack the other patch? I
> sent a v4 for the pointer obfuscation, which we really need:
> https://lkml.org/lkml/2017/7/26/4

Just looked through it.
