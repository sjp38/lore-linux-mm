Message-ID: <48AB2BCE.1080607@linux-foundation.org>
Date: Tue, 19 Aug 2008 15:23:42 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with	_RET_IP_.
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro> <48AB0D69.4090703@linux-foundation.org> <20080819182423.GA5520@localhost> <48AB1769.3040703@linux-foundation.org> <48AB1A5B.3020305@cs.helsinki.fi> <48AB2A4A.7040103@linux-foundation.org> <48AB2A01.2050500@cs.helsinki.fi>
In-Reply-To: <48AB2A01.2050500@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:

> It's compiled-tested too. I had to do some changes to
> include/linux/slab.h as well.

Please recompile with CONFIG_SLUB_DEBUG off to find some breakage.  F.e.

static inline int alloc_debug_processing(struct kmem_cache *s,
        struct page *page, void *object, void *addr) { return 0; }

static inline int free_debug_processing(struct kmem_cache *s,
        struct page *page, void *object, void *addr) { return 0; }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
