Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id CDC626B00B9
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 17:45:30 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id 29so2538758yhl.37
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:45:30 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id c58si13141912yha.22.2014.09.10.14.45.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 14:45:30 -0700 (PDT)
Message-ID: <1410384895.28990.312.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 6/6] x86, pat: Update documentation for WT changes
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 10 Sep 2014 15:34:55 -0600
In-Reply-To: <CALCETrUh20-2PX_KN2KWO085n=5XJpOnPysmCGbk7bufaD3Mhw@mail.gmail.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
	 <1410367910-6026-7-git-send-email-toshi.kani@hp.com>
	 <CALCETrVnHg0X=R23qyiPtxYs3knHaXq65L0Jw_1oY4=gX5kpXQ@mail.gmail.com>
	 <1410379933.28990.287.camel@misato.fc.hp.com>
	 <CALCETrUh20-2PX_KN2KWO085n=5XJpOnPysmCGbk7bufaD3Mhw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, 2014-09-10 at 13:29 -0700, Andy Lutomirski wrote:
> On Wed, Sep 10, 2014 at 1:12 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > On Wed, 2014-09-10 at 11:30 -0700, Andy Lutomirski wrote:
> >> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> >> > +Drivers may map the entire NV-DIMM range with ioremap_cache and then change
> >> > +a specific range to wt with set_memory_wt.
> >>
> >> That's mighty specific :)
> >
> > How about below?
> >
> > Drivers may use set_memory_wt to set WT type for cached reserve ranges.
> 
> Do they have to be cached?

Yes, set_memory_xyz only supports WB->type->WB transition.

> How about:
> 
> Drivers may call set_memory_wt on ioremapped ranges.  In this case,
> there is no need to change the memory type back before calling
> iounmap.
> 
> (Or only on cached ioremapped ranges if that is, in fact, the case.)

Sounds good.  Yes, I will use cashed ioremapped ranges.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
