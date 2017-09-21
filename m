From: Christopher Lameter <cl@linux.com>
Subject: Re: [kernel-hardening] Re: [PATCH v3 03/31] usercopy: Mark kmalloc
 caches as usercopy caches
Date: Thu, 21 Sep 2017 11:04:35 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709211102320.14742@nuc-kabylake>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org> <1505940337-79069-4-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1709211024120.14427@nuc-kabylake> <CAGXu5j+X6dWCGocG=P7pszTY-5OZ6Jmp-RsnDKox75M5rmVe4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5j+X6dWCGocG=P7pszTY-5OZ6Jmp-RsnDKox75M5rmVe4g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-xfs@vger.kernel.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
List-Id: linux-mm.kvack.org

On Thu, 21 Sep 2017, Kees Cook wrote:

> > So what is the point of this patch?
>
> The DMA kmalloc caches are not whitelisted:

The DMA kmalloc caches are pretty obsolete and mostly there for obscure
drivers.

??

> >>                         kmalloc_dma_caches[i] = create_kmalloc_cache(n,
> >> -                               size, SLAB_CACHE_DMA | flags);
> >> +                               size, SLAB_CACHE_DMA | flags, 0, 0);
>
> So this is creating the distinction between the kmallocs that go to
> userspace and those that don't. The expectation is that future work
> can start to distinguish between "for userspace" and "only kernel"
> kmalloc allocations, as is already done here for DMA.

The creation of the kmalloc caches in earlier patches already setup the
"whitelisting". Why do it twice?
