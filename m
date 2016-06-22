Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 476F16B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 16:10:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so42558757lfa.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 13:10:22 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id 36si1206812lfv.21.2016.06.22.13.10.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 13:10:20 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id h129so81970001lfh.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 13:10:20 -0700 (PDT)
Date: Wed, 22 Jun 2016 23:10:18 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: JITs and 52-bit VA
Message-ID: <20160622201018.GC2045@uranus.lan>
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
 <20160622191843.GA2045@uranus.lan>
 <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
 <576AED88.6040805@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <576AED88.6040805@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On Wed, Jun 22, 2016 at 12:56:56PM -0700, Dave Hansen wrote:
> >> > +1. Also it might be (not sure though, just guessing) suitable to do such
> >> > thing via memory cgroup controller, instead of carrying this limit per
> >> > each process (or task structure/vma or mm).
> > I think we'll want this per mm.  After all, a high-VA-limit-aware bash
> > should be able run high-VA-unaware programs without fiddling with
> > cgroups.
> 
> Yeah, cgroups don't make a lot of sense.

cgroups make sense in terms of shriking data: we only need to
setup the limit once and every process lives in the cgroup
get the limit, no need to carry it per every mm. So I guessed
it might be usefull.

> On x86, the 48-bit virtual address is even hard-coded in the ABI[1].  So
> we can't change *any* program's layout without either breaking the ABI
> or having it opt in.
> 
> But, we're also lucky to only have one VA layout since day one.
> 
> 1. www.x86-64.org/documentation/abi.pdf - a??... Therefore, conforming
> processes may only use addresses from 0x00000000 00000000 to 0x00007fff
> ffffffff .a??

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
