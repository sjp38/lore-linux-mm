Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10D626B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 17:49:33 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so56896546pfk.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 14:49:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n28si28605945pgd.148.2016.11.07.14.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 14:49:32 -0800 (PST)
Date: Mon, 7 Nov 2016 14:49:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/2] memcg: Prevent memcg caches to be both OFF_SLAB
 & OBJFREELIST_SLAB
Message-Id: <20161107144931.edcf151a04f1af6d230b8a8a@linux-foundation.org>
In-Reply-To: <CAJcbSZGO1oVf2cQeCO2_qiUrNdSckhwDSah4sqnnc388J2Rruw@mail.gmail.com>
References: <1478553075-120242-1-git-send-email-thgarnie@google.com>
	<20161107141919.fe50cef419918c7a4660f3c2@linux-foundation.org>
	<CAJcbSZGO1oVf2cQeCO2_qiUrNdSckhwDSah4sqnnc388J2Rruw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Mon, 7 Nov 2016 14:32:56 -0800 Thomas Garnier <thgarnie@google.com> wrote:

> On Mon, Nov 7, 2016 at 2:19 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Mon,  7 Nov 2016 13:11:14 -0800 Thomas Garnier <thgarnie@google.com> wrote:
> >
> >> From: Greg Thelen <gthelen@google.com>
> >>
> >> While testing OBJFREELIST_SLAB integration with pagealloc, we found a
> >> bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
> >> CFLGS_OBJFREELIST_SLAB.
> >>
> >> The original kmem_cache is created early making OFF_SLAB not possible.
> >> When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
> >> is enabled it will try to enable it first under certain conditions.
> >> Given kmem_cache(sys) reuses the original flag, you can have both flags
> >> at the same time resulting in allocation failures and odd behaviors.
> >
> > Can we please have a better description of the problems which this bug
> > causes?  Without this info it's unclear to me which kernel version(s)
> > need the fix.
> >
> > Given that the bug is 6 months old I'm assuming "not very urgent".
> >
> 
> I will add more details and send another round.

Please simply send the additional changelog text in this thread -
processing an entire v4 patch just for a changelog fiddle is rather
heavyweight.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
