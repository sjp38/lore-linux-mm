Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id CD3116B0099
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:31:49 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id p9so10560691lbv.14
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:31:49 -0700 (PDT)
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
        by mx.google.com with ESMTPS id 1si17763106lal.89.2014.09.10.13.31.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:31:48 -0700 (PDT)
Received: by mail-lb0-f174.google.com with SMTP id n15so11815957lbi.33
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:31:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5410B10A.4030207@zytor.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
 <1410367910-6026-3-git-send-email-toshi.kani@hp.com> <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
 <1410377428.28990.260.camel@misato.fc.hp.com> <5410B10A.4030207@zytor.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 10 Sep 2014 13:31:27 -0700
Message-ID: <CALCETrX5JEZ3cLbuehobnH3bmBDAKARV9o0V5VYoazV8rL5o-A@mail.gmail.com>
Subject: Re: [PATCH v2 2/6] x86, mm, pat: Change reserve_memtype() to handle WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, Sep 10, 2014 at 1:14 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 09/10/2014 12:30 PM, Toshi Kani wrote:
>>
>> When WT is unavailable due to the PAT errata, it does not fail but gets
>> redirected to UC-.  Similarly, when PAT is disabled, WT gets redirected
>> to UC- as well.
>>
>
> But on pre-PAT hardware you can still do WT.
>

Using MTRRs?  /me shudders, although I suppose this would be okay for
NV-DIMMs as long as you map the whole thing WT.

One of these days I'll finish excising mtrr_add from everything
outside arch/x86.  I already killed it in all modern graphics drivers
:)

--Andy



>         -hpa
>



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
