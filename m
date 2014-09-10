Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 628AA6B0083
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:51:03 -0400 (EDT)
Received: by mail-yk0-f179.google.com with SMTP id 142so2767524ykq.24
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:51:03 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id i4si12928388yha.27.2014.09.10.12.51.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 12:51:02 -0700 (PDT)
Message-ID: <1410378027.28990.268.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 3/6] x86, mm, asm-gen: Add ioremap_wt() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 10 Sep 2014 13:40:27 -0600
In-Reply-To: <CALCETrWoCYWRSDXy0W8vEhdiEKmuETMRpDMWRgYvVx71MeeTkg@mail.gmail.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
	 <1410367910-6026-4-git-send-email-toshi.kani@hp.com>
	 <CALCETrWoCYWRSDXy0W8vEhdiEKmuETMRpDMWRgYvVx71MeeTkg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, 2014-09-10 at 11:29 -0700, Andy Lutomirski wrote:
> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
 :
> > +#ifndef ARCH_HAS_IOREMAP_WT
> > +#define ioremap_wt ioremap_nocache
> > +#endif
> > +
> 
> This is a little bit sad.  I wouldn't be too surprised if there are
> eventually users who prefer WC or WB over UC if WT isn't available
> (and they'll want a corresponding way to figure out what kind of fence
> to use).

Right, this redirection is not ideal for the performance, but it is done
this way for the correctness.  WT & UC have strongly ordered writes, but
WB & WC do not.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
