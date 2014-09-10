Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5C13D6B008C
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:22:51 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so6448112pad.9
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:22:51 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id hn2si29284006pbc.82.2014.09.10.13.22.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:22:50 -0700 (PDT)
Message-ID: <1410379933.28990.287.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 6/6] x86, pat: Update documentation for WT changes
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 10 Sep 2014 14:12:13 -0600
In-Reply-To: <CALCETrVnHg0X=R23qyiPtxYs3knHaXq65L0Jw_1oY4=gX5kpXQ@mail.gmail.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
	 <1410367910-6026-7-git-send-email-toshi.kani@hp.com>
	 <CALCETrVnHg0X=R23qyiPtxYs3knHaXq65L0Jw_1oY4=gX5kpXQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, 2014-09-10 at 11:30 -0700, Andy Lutomirski wrote:
> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> > +Drivers may map the entire NV-DIMM range with ioremap_cache and then change
> > +a specific range to wt with set_memory_wt.
> 
> That's mighty specific :)

How about below?

Drivers may use set_memory_wt to set WT type for cached reserve ranges.

> It's also not all that informative.  Are you supposed to set the
> memory back before iounmapping?  

Setting back to WB before iounmap is not required, but set_memory_wb is
used when it wants to put it back to WB before unmapping.

> Can you do this with set_memory_wc on
> an uncached mapping?

The table lists interfaces and their intended usage.  Using
set_memory_wc on an uncached mapping probably works, but is not an
intended use.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
