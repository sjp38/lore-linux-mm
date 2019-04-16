Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0803C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 700812075B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:21:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 700812075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 007896B0007; Tue, 16 Apr 2019 17:21:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF98D6B0008; Tue, 16 Apr 2019 17:21:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0E486B000A; Tue, 16 Apr 2019 17:21:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9398E6B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 17:21:34 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id m13so20058953wrr.17
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:21:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=9ZYYpvFstgTUiKuSYOJPtkQmI45J0YOwxcMgwsqo/6Q=;
        b=T8uxTeMRtwt/OlRIg9RaLIhOMNo7QIurSiWcUY4nl/Bs/iGrON1TlUBp1s5kfguK20
         jA5mlZ2zGTJ8v6EJRVR139WVKgJ4djG/pT2xfMXOpkkoMPmD9c8FIAh4SP6ZeUbhOzlN
         t9Wl46J+xeeNfWBrfCmbOIrh8TV6rua+CLWA2O5uAlu+ncZMX+gQL4+kNQ2Yzmjltrdc
         /X3lzgOCrMAmYV+uYyzmv9rl0ygH9dRsb1yBl/RrrzBz4xY3y6ZuDxe30k8kKZ0SNJm/
         Zou1wcNiQ5Tje1aJHq29hk1NuGlWCtI1mjTejzdmDyUP0ADE95TLPx4Tg7tnXaij/T1f
         Gw2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVyBmx8y1uSDAWYv6m/LLKH/s350XF30GNSbuVs8W+TZSljaXx1
	pKjbWQSRCiO7aF2G3sNNlNOVA2qY1CtH3+/n86VXTVuRjlrMA/Uy6nT/+aFNlFUYkGeT2QVj8t0
	SC5r7it+80xue7TpOrRMq40dSr0bysvknurm5d7AdABL70UtmiYJOJj1xKWPMh5eOHw==
X-Received: by 2002:a1c:1a46:: with SMTP id a67mr29019712wma.21.1555449694102;
        Tue, 16 Apr 2019 14:21:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiXDSUL2Zt99tzvhrux53023n3Xy3htMyyV2ScC7djlWu/taaNklvLwZ+JhEL6VVwHMOfm
X-Received: by 2002:a1c:1a46:: with SMTP id a67mr29019672wma.21.1555449692968;
        Tue, 16 Apr 2019 14:21:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555449692; cv=none;
        d=google.com; s=arc-20160816;
        b=x9g2NpAg/SFB5wOggxASTDu9Y80aGENHKsmWQLhkHv8WRNWqhzRp9AklP7V6dFfFkB
         zD7MeO6HJrCEsg9LJGqcyJTlm9IX2Cujy3J8anHVCVuPeWbM26nWYUVfGfw3/HOc8bNa
         fBTK4TbZvJ8P8nAA34Msz1YBq5xwAD98fnGAOeajj43rISJ2b7rsg/KasJAZ00Vvnlo7
         s9P39TAhREqoBTc+L3xdT/gnKtLQXl7eK0U9avdU7WWZiSzqT1f16PmJXVIc8KwcLsfd
         iV//b26ryjHZfhXL4QKEW2sFTVxv14CgulyE2jlzxX9X78sKaE97RgnoXr6ROTgMWYsq
         RaNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=9ZYYpvFstgTUiKuSYOJPtkQmI45J0YOwxcMgwsqo/6Q=;
        b=ITufiY4gk/2VFtGxCoefi4l9Ubtih3u+i6oztHFMUPkSR1XaUPDjzsnEXNIVdDRhoT
         WiPp7iBs0nBnICpbp5+cFPi8OrZvZ0ep7RUmKMEcs+2kr8+Rp14sgve872oU/4ABhIFl
         jwKiS0nNPejE4R2DDQE4h/v5q7A12Z6SGGzIolFIwdg5FIPZ0aQETWESfD1/CZYdJfK9
         NK9ximpvt0otphkvFfqwgqURpPW6NV0mA7Gf8gACuIGpN5/N61NDx9HE12dy3yEmRkzc
         BS+KVtfC2d1oQj7ttQhdbf/S63/+QFf34xnZKiGo+44JGthFBG+ZhPs1Nvs0GhRTEvwa
         kSIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d191si364592wmd.39.2019.04.16.14.21.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 14:21:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hGVWB-0004ui-BW; Tue, 16 Apr 2019 23:21:27 +0200
Date: Tue, 16 Apr 2019 23:21:26 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Vlastimil Babka <vbabka@suse.cz>
cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, luto@kernel.org, 
    jpoimboe@redhat.com, sean.j.christopherson@intel.com, penberg@kernel.org, 
    rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] slab: remove store_stackinfo()
In-Reply-To: <235d7500-8235-c7d4-0d6f-4d069133bd8d@suse.cz>
Message-ID: <alpine.DEB.2.21.1904162320190.1780@nanos.tec.linutronix.de>
References: <20190416142258.18694-1-cai@lca.pw> <902fed9c-9655-a241-677d-5fa11b6c95a1@suse.cz> <alpine.DEB.2.21.1904162040570.1780@nanos.tec.linutronix.de> <235d7500-8235-c7d4-0d6f-4d069133bd8d@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Apr 2019, Vlastimil Babka wrote:
> On 4/16/2019 8:50 PM, Thomas Gleixner wrote:
> > On Tue, 16 Apr 2019, Vlastimil Babka wrote:
> > 
> >> On 4/16/19 4:22 PM, Qian Cai wrote:
> >>> store_stackinfo() does not seem used in actual SLAB debugging.
> >>> Potentially, it could be added to check_poison_obj() to provide more
> >>> information, but this seems like an overkill due to the declining
> >>> popularity of the SLAB, so just remove it instead.
> >>>
> >>> Signed-off-by: Qian Cai <cai@lca.pw>
> >>
> >> I've acked Thomas' version already which was narrower, but no objection
> >> to remove more stuff on top of that. Linus (and I later in another
> >> thread) already pointed out /proc/slab_allocators. It only takes a look
> >> at add_caller() there to not regret removing that one.
> > 
> > The issue why I was looking at this was a krobot complaint about the kernel
> > crashing in that stack store function with my stackguard series applied. It
> > was broken before the stackguard pages already, it just went unnoticed.
> > 
> > As you explained, nobody is caring about DEBUG_SLAB + DEBUG_PAGEALLOC
> > anyway, so I'm happy to not care about krobot tripping over it either.
> > 
> > So we have 3 options:
> > 
> >    1) I ignore it and merge the stack guard series w/o it
> > 
> >    2) I can carry the minimal fix or Qian's version in the stackguard
> >       branch
> > 
> >    3) We ship that minimal fix to Linus right now and then everyone can
> >       base their stuff on top independently.
> 
> I think #3 is overkill for something that was broken for who knows how long and
> nobody noticed. I'd go with 2) and perhaps Qian's version as nobody AFAIK uses
> the caller+cpu as well as the stack trace.
> 
> For Qian's version also:
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Ok. I'll pick it up and base the stackguard stuff on top.

Thanks,

	tglx

