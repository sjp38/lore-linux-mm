Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC01F6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 17:38:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so11131301wme.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 14:38:50 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id o83si1381621lfi.114.2016.06.22.14.38.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 14:38:49 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id h129so83294307lfh.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 14:38:49 -0700 (PDT)
Date: Thu, 23 Jun 2016 00:38:46 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: JITs and 52-bit VA
Message-ID: <20160622213846.GF2045@uranus.lan>
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
 <20160622191843.GA2045@uranus.lan>
 <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
 <20160622194425.GB2045@uranus.lan>
 <CALCETrULT6Kp_sA4+3=MgFoS0WSzfCmzPvk8dj89raqLC86XKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrULT6Kp_sA4+3=MgFoS0WSzfCmzPvk8dj89raqLC86XKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On Wed, Jun 22, 2016 at 01:46:18PM -0700, Andy Lutomirski wrote:
> >>
> >> I think we'll want this per mm.  After all, a high-VA-limit-aware bash
> >> should be able run high-VA-unaware programs without fiddling with
> >> cgroups.
> >
> > Wait. You mean to have some flag in mm struct and consider
> > its value on mmap call?
> 
> Exactly.

I see. Thanks for info!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
