Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6C706B03A6
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:31:00 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id o79so4434492ioo.14
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:31:00 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id 186si2439913itk.52.2017.04.11.09.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 09:31:00 -0700 (PDT)
Received: by mail-io0-x22e.google.com with SMTP id t68so10859767iof.0
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:30:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1704111122550.25069@east.gentwo.org>
References: <20170404113022.GC15490@dhcp22.suse.cz> <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
 <20170404151600.GN15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
 <20170404194220.GT15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
 <20170404201334.GV15132@dhcp22.suse.cz> <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
 <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz> <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
 <CAGXu5jK1j3UWUakakFw=EfVwg+Rnovzst52+uZJYesLqLY+n5A@mail.gmail.com> <alpine.DEB.2.20.1704111122550.25069@east.gentwo.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 11 Apr 2017 09:30:58 -0700
Message-ID: <CAGXu5jLLFg78iG2LBwwNQesi4Tir-4wBXLHg=HOAPa-+Lr7GXQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Add additional consistency check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 11, 2017 at 9:23 AM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 11 Apr 2017, Kees Cook wrote:
>
>> It seems that enabling the debug checks comes with a non-trivial
>> performance impact. I'd like to see consistency checks by default so
>> we can handle intentional heap corruption attacks better. This check
>> isn't expensive...
>
> Its in a very hot code and frequently used code path.

Yeah, absolutely. All the more reason to make sure the kernel can't be
attacked through it. :) As with the automotive industry analogy[1]
from Konstantin, we need to make sure Linux not only run fast and
efficiently, but also fails gracefully by default.

> Note also that these checks can be enabled and disabled at runtime for
> each slab cache.

Correct, but my understanding is that enabling them through the debug
system ends up being much more expensive than this smaller check. The
debug code is fairly comprehensive, but it's not been designed for
efficient attack detection, etc.

-Kees

[1] http://kernsec.org/files/lss2015/giant-bags-of-mostly-water.pdf

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
