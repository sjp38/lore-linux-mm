Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1AADD6B0095
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:30:11 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z11so8141269lbi.35
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:30:11 -0700 (PDT)
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
        by mx.google.com with ESMTPS id ll10si14604804lac.40.2014.09.10.13.30.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:30:10 -0700 (PDT)
Received: by mail-lb0-f173.google.com with SMTP id w7so6585342lbi.32
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:30:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410379933.28990.287.camel@misato.fc.hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
 <1410367910-6026-7-git-send-email-toshi.kani@hp.com> <CALCETrVnHg0X=R23qyiPtxYs3knHaXq65L0Jw_1oY4=gX5kpXQ@mail.gmail.com>
 <1410379933.28990.287.camel@misato.fc.hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 10 Sep 2014 13:29:49 -0700
Message-ID: <CALCETrUh20-2PX_KN2KWO085n=5XJpOnPysmCGbk7bufaD3Mhw@mail.gmail.com>
Subject: Re: [PATCH v2 6/6] x86, pat: Update documentation for WT changes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, Sep 10, 2014 at 1:12 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> On Wed, 2014-09-10 at 11:30 -0700, Andy Lutomirski wrote:
>> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
>> > +Drivers may map the entire NV-DIMM range with ioremap_cache and then change
>> > +a specific range to wt with set_memory_wt.
>>
>> That's mighty specific :)
>
> How about below?
>
> Drivers may use set_memory_wt to set WT type for cached reserve ranges.

Do they have to be cached?

How about:

Drivers may call set_memory_wt on ioremapped ranges.  In this case,
there is no need to change the memory type back before calling
iounmap.

(Or only on cached ioremapped ranges if that is, in fact, the case.)

--Andy

>
>> It's also not all that informative.  Are you supposed to set the
>> memory back before iounmapping?
>
> Setting back to WB before iounmap is not required, but set_memory_wb is
> used when it wants to put it back to WB before unmapping.
>
>> Can you do this with set_memory_wc on
>> an uncached mapping?
>
> The table lists interfaces and their intended usage.  Using
> set_memory_wc on an uncached mapping probably works, but is not an
> intended use.
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
