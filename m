Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3D0828E1
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 16:24:18 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l184so42041719lfl.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 13:24:18 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id 143si1161175ljj.79.2016.06.22.13.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 13:24:17 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id l188so81003990lfe.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 13:24:16 -0700 (PDT)
Date: Wed, 22 Jun 2016 23:24:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: JITs and 52-bit VA
Message-ID: <20160622202414.GA20027@node.shutemov.name>
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
 <20160622191843.GA2045@uranus.lan>
 <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
 <576AED88.6040805@intel.com>
 <20160622201754.GD2045@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160622201754.GD2045@uranus.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On Wed, Jun 22, 2016 at 11:17:54PM +0300, Cyrill Gorcunov wrote:
> On Wed, Jun 22, 2016 at 12:56:56PM -0700, Dave Hansen wrote:
> > 
> > Yeah, cgroups don't make a lot of sense.
> > 
> > On x86, the 48-bit virtual address is even hard-coded in the ABI[1].  So
> > we can't change *any* program's layout without either breaking the ABI
> > or having it opt in.
> > 
> > But, we're also lucky to only have one VA layout since day one.
> > 
> > 1. www.x86-64.org/documentation/abi.pdf - a??... Therefore, conforming
> > processes may only use addresses from 0x00000000 00000000 to 0x00007fff
> > ffffffff .a??
> 
> Yes, but noone forces you to write conforming programs ;)
> After all while hw allows you to run VA with bits > than
> 48 it's fine, all side effects of breaking abi is up to
> program author (iirc on x86 there is up to 52 bits on
> hw level allowed, don't have specs under my hands?)

Nope. 48-bit VA (47-bit to userspace) and 46-bit PA.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
