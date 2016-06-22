Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D78D36B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 15:44:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so9539021wmr.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:44:29 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id i65si1167374lfb.27.2016.06.22.12.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 12:44:28 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id l188so15364789lfe.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:44:28 -0700 (PDT)
Date: Wed, 22 Jun 2016 22:44:25 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: JITs and 52-bit VA
Message-ID: <20160622194425.GB2045@uranus.lan>
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
 <20160622191843.GA2045@uranus.lan>
 <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On Wed, Jun 22, 2016 at 12:20:13PM -0700, Andy Lutomirski wrote:
> >>
> >> As an example, a 32-bit x86 program really could have something mapped
> >> above the 32-bit boundary.  It just wouldn't be useful, but the kernel
> >> should still understand that it's *user* memory.
> >>
> >> So you'd have PR_SET_MMAP_LIMIT and PR_GET_MMAP_LIMIT or similar instead.
> >
> > +1. Also it might be (not sure though, just guessing) suitable to do such
> > thing via memory cgroup controller, instead of carrying this limit per
> > each process (or task structure/vma or mm).
> 
> I think we'll want this per mm.  After all, a high-VA-limit-aware bash
> should be able run high-VA-unaware programs without fiddling with
> cgroups.

Wait. You mean to have some flag in mm struct and consider
its value on mmap call?

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
