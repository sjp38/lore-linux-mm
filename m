From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or
 corruption
Date: Wed, 19 Jul 2017 09:02:27 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707190901260.17716@nuc-kabylake>
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com> <20170717175459.GC14983@bombadil.infradead.org> <alpine.DEB.2.20.1707171303230.12109@nuc-kabylake> <c86c66c3-29d8-0b04-b4d1-f9f8192d8c4a@linux.com> <CAGXu5jK5j2pSVca9XGJhJ6pnF04p7S=K1Z432nzG2y4LfKhYjg@mail.gmail.com>
 <1edb137c-356f-81d6-4592-f5dfc68e8ea9@linux.com> <CAGXu5jL0bFpWqUm9d2X7zpTO_CwPp94ywcLYoFyNcLuiwX8qAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jL0bFpWqUm9d2X7zpTO_CwPp94ywcLYoFyNcLuiwX8qAQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Popov <alex.popov@linux.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
List-Id: linux-mm.kvack.org

On Tue, 18 Jul 2017, Kees Cook wrote:

> I think there are two issues: first, this should likely be under
> CONFIG_FREELIST_HARDENED since Christoph hasn't wanted to make these
> changes enabled by default (if I'm understanding his earlier review
> comments to me). The second issue is what to DO when a double-free is
> discovered. Is there any way to make it safe/survivable? If not, I

The simple thing is to not free the object when you discover this. That is
what the existing debugging code does. But you do not have an easy way to
fail at the point in the code that is patched here.
