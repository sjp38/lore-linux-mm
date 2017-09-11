Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF47F6B02D2
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 11:02:08 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m30so9714528pgn.2
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 08:02:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i13sor3996107pgf.76.2017.09.11.08.02.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 08:02:07 -0700 (PDT)
Date: Mon, 11 Sep 2017 08:02:04 -0700
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 00/11] Add support for eXclusive Page Frame Ownership
Message-ID: <20170911150204.nn5v5olbxyzfafou@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <23e5bac9-329a-3a32-049e-7e7c9751abd0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23e5bac9-329a-3a32-049e-7e7c9751abd0@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

Hi Yisheng,

On Mon, Sep 11, 2017 at 06:34:45PM +0800, Yisheng Xie wrote:
> Hi Tycho ,
> 
> On 2017/9/8 1:35, Tycho Andersen wrote:
> > Hi all,
> > 
> > Here is v6 of the XPFO set; see v5 discussion here:
> > https://lkml.org/lkml/2017/8/9/803
> > 
> > Changelogs are in the individual patch notes, but the highlights are:
> > * add primitives for ensuring memory areas are mapped (although these are quite
> >   ugly, using stack allocation; I'm open to better suggestions)
> > * instead of not flushing caches, re-map pages using the above
> > * TLB flushing is much more correct (i.e. we're always flushing everything
> >   everywhere). I suspect we may be able to back this off in some cases, but I'm
> >   still trying to collect performance numbers to prove this is worth doing.
> > 
> > I have no TODOs left for this set myself, other than fixing whatever review
> > feedback people have. Thoughts and testing welcome!
> 
> According to the paper of Vasileios P. Kemerlis et al, the mainline kernel
> will not set the Pro. of physmap(direct map area) to RW(X), so do we really
> need XPFO to protect from ret2dir attack?

I guess you're talking about section 4.3? They mention that that x86
only gets rw, but that aarch64 is rwx still.

But in either case this still provides access protection, similar to
SMAP. Also, if I understand things correctly the protections are
unmanaged, so a page that had the +x bit set at some point, it could
be used for ret2dir.

Cheers,

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
