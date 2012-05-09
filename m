Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id DE5EA6B0101
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:14:12 -0400 (EDT)
Date: Wed, 9 May 2012 09:14:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: BUG at mm/slub.c:374
In-Reply-To: <CAFLxGvy0PHZHVL9rZx_0oFGobKftPBc0EN3VEyzNqvg13FUEfw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205090907070.8171@router.home>
References: <CAFLxGvy0PHZHVL9rZx_0oFGobKftPBc0EN3VEyzNqvg13FUEfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 9 May 2012, richard -rw- weinberger wrote:

> A few minutes ago I saw this BUG within one of my KVM machines.
> Config is attached.

Interrupts on in __cmpxchg_double_slab called from __slab_alloc? Does KVM
do some tricks with interrupt flags? I do not see how that can be
otherwise since __slab_alloc disables interrupts on entry and reenables on
exit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
