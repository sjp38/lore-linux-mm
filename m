Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 32ECA6B0087
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:09:01 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id w7so6519416lbi.4
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:09:00 -0700 (PDT)
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
        by mx.google.com with ESMTPS id qy5si22779148lbb.62.2014.09.10.13.08.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:08:59 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id v6so5409281lbi.20
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:08:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410378027.28990.268.camel@misato.fc.hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
 <1410367910-6026-4-git-send-email-toshi.kani@hp.com> <CALCETrWoCYWRSDXy0W8vEhdiEKmuETMRpDMWRgYvVx71MeeTkg@mail.gmail.com>
 <1410378027.28990.268.camel@misato.fc.hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 10 Sep 2014 13:08:38 -0700
Message-ID: <CALCETrXc-ecEt6mMuZee=MaoHD77XPWhjAJJUOgeXkcNZhC=Og@mail.gmail.com>
Subject: Re: [PATCH v2 3/6] x86, mm, asm-gen: Add ioremap_wt() for WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, Sep 10, 2014 at 12:40 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> On Wed, 2014-09-10 at 11:29 -0700, Andy Lutomirski wrote:
>> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
>  :
>> > +#ifndef ARCH_HAS_IOREMAP_WT
>> > +#define ioremap_wt ioremap_nocache
>> > +#endif
>> > +
>>
>> This is a little bit sad.  I wouldn't be too surprised if there are
>> eventually users who prefer WC or WB over UC if WT isn't available
>> (and they'll want a corresponding way to figure out what kind of fence
>> to use).
>
> Right, this redirection is not ideal for the performance, but it is done
> this way for the correctness.  WT & UC have strongly ordered writes, but
> WB & WC do not.

Fair enough.  I think that this is unlikely to ever matter on x86, but
it might if NV-DIMMs end up used on another architecture w/o WT (or on
Xen, perhaps).  Your code is certainly fine from a correctness POV.

Aside: WB writes are IIRC even more strongly ordered than WC.

>
> Thanks,
> -Toshi
>



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
