Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 675926B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 07:31:26 -0400 (EDT)
Received: by lahi5 with SMTP id i5so1495508lah.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 04:31:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205090907070.8171@router.home>
References: <CAFLxGvy0PHZHVL9rZx_0oFGobKftPBc0EN3VEyzNqvg13FUEfw@mail.gmail.com>
	<alpine.DEB.2.00.1205090907070.8171@router.home>
Date: Thu, 10 May 2012 13:31:24 +0200
Message-ID: <CAFLxGvymF0yo3k_j6EON-nk9=mQDaL72mnBxxJOv2awiWgjeYQ@mail.gmail.com>
Subject: Re: BUG at mm/slub.c:374
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, May 9, 2012 at 4:14 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 9 May 2012, richard -rw- weinberger wrote:
>
>> A few minutes ago I saw this BUG within one of my KVM machines.
>> Config is attached.
>
> Interrupts on in __cmpxchg_double_slab called from __slab_alloc? Does KVM
> do some tricks with interrupt flags? I do not see how that can be
> otherwise since __slab_alloc disables interrupts on entry and reenables on
> exit.

Dunno.
So far I've seen this BUG only once. :-\

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
