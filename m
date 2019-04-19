Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4728EC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 08:32:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD435218AE
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 08:32:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD435218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AA586B0003; Fri, 19 Apr 2019 04:32:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37F276B0006; Fri, 19 Apr 2019 04:32:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 248D06B0007; Fri, 19 Apr 2019 04:32:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8FCC6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 04:32:48 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 7so3900102wmj.9
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 01:32:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=p3V+WOTuUdZHAdmzhtTm9PRZspQIxsuSMkvv8mL4NLY=;
        b=VN3lkFDHQ0hZtOMLnO6Y30UOAgh+IEERRCWdfTHnPet9TLqJGFN3MM9Z6XJQfRpzDS
         Znu9FUMdWfIezn8o6PwjzlMLBlSdGEurHUhJ+ZoYcCjNBGenei4JdKWhdJyJD79kCdqV
         4SuO/sXDKcT6VDCYxTLEVHHY11n3XocNuw0WxQwVfKv6Qnz6EfhGOGJWvtnaO4Hqa6mP
         o/4RR7hZ73v2oqxfxqCK0ufqR4OG6Q1EynBbRu/T12ChpFPOSuSJMh5nhJDZjlHSvn+X
         7buOmPc21CY7jvJG/GPZMdSz078ukYByXkLFO8NCHIyA3AcdUdMHQfYhWuuuMMFpIyFX
         gdGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUE9ctviJAh5sLR4Ugwu1AHT8J+rMbMMVq9viFRnMLwIrWq+j9c
	SVA3ZmZWDfDwCzbetaO9+2+0PCARix2sj2O/sCc3Zt/rt6NGno8ZMDrw9Pz4wiefBpIOgbbkjiI
	b1izyvRTtwgtekuKY2cyhApRUJYfvJ0Pa/7iw2nGe73a6VGhmQcl6MsIIkeXW26DB3A==
X-Received: by 2002:a1c:6502:: with SMTP id z2mr1738563wmb.119.1555662768193;
        Fri, 19 Apr 2019 01:32:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzh2oLLgziQX0kj/7yUu+5NnZDjHaKePPJCaRZmD5YUg4CEpWrCPZhFOipETT6uXEkVfDtV
X-Received: by 2002:a1c:6502:: with SMTP id z2mr1738506wmb.119.1555662767126;
        Fri, 19 Apr 2019 01:32:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555662767; cv=none;
        d=google.com; s=arc-20160816;
        b=XA3SNf0Rlq0le7lyrFkL1aNgFtGPVIbLfoJhz/G0uE5G83ySo7Txhvsr9fRWkq7X2/
         HDzb6MMWhPPbTgLZGw++V654NmV/InoN9cKROkHmt946q350gkTM6ZNknwUFnXRAuB3/
         YfJwXnhurgLOxCztEKvH6xlo670OAXo8iiINBAAq2YPQz5kdoTf+Lo24rGjeOs1YkzN/
         0c2CXY279mcfKf9AOAD8i5yLZMD1FxSvbINwETs9raSNVvIpWQm6OxxUyKRu4jNJzSVb
         HMaUDruwVDztq9OnIpqqDyjfh97D3JCznBZBzRkGz/E3oO5eG4uEaO/lIi2Q9EBV0J86
         81SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=p3V+WOTuUdZHAdmzhtTm9PRZspQIxsuSMkvv8mL4NLY=;
        b=X5Z15Qw2qwiDydpFL5hIul8nr7yAwoD9DZnZrRHBP9aLxYJnNAWYJfg3BpQwDlR38H
         4qtBKeC3V6fcpDj2vlFgIQ0SRoMKlXUx+NPInJz09lufBe/J/sCqqm5mPjCiyA3bOf6/
         vKSg0ZU285ahOj5QF9sEIvd6KFY2NRPOz5h2E4nuYY8gefBvbM7XSqvGiIbg7rDqKizr
         24DXoz7EMBmSFeZsMfxl1dr+t5W27B/x98uqA53icCyA4gM3blODC5Sg+Qgik5o2s2nY
         AJ5x9on1t3NxMHtTNZky2ZANA3QdgVs/UXoyJYhz8iXsEXpOwuxhFbBZCwmfRO6M/Uiv
         2xhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j5si2861095wrx.365.2019.04.19.01.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 19 Apr 2019 01:32:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hHOwh-0001UI-Ot; Fri, 19 Apr 2019 10:32:31 +0200
Date: Fri, 19 Apr 2019 10:32:30 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <peterz@infradead.org>
cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    x86@kernel.org, Andy Lutomirski <luto@kernel.org>, 
    Steven Rostedt <rostedt@goodmis.org>, 
    Alexander Potapenko <glider@google.com>, linux-arch@vger.kernel.org, 
    Alexey Dobriyan <adobriyan@gmail.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, 
    David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Dmitry Vyukov <dvyukov@google.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, 
    Mike Rapoport <rppt@linux.vnet.ibm.com>, 
    Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org, 
    Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, 
    Marek Szyprowski <m.szyprowski@samsung.com>, 
    Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, 
    Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, 
    linux-btrfs@vger.kernel.org, dm-devel@redhat.com, 
    Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, 
    intel-gfx@lists.freedesktop.org, 
    Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
    Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, 
    dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, 
    Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>, 
    Rodrigo Vivi <rodrigo.vivi@intel.com>
Subject: Re: [patch V2 28/29] stacktrace: Provide common infrastructure
In-Reply-To: <20190419071843.GM4038@hirez.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.21.1904191031390.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de> <20190418084255.652003111@linutronix.de> <20190419071843.GM4038@hirez.programming.kicks-ass.net>
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

On Fri, 19 Apr 2019, Peter Zijlstra wrote:
> On Thu, Apr 18, 2019 at 10:41:47AM +0200, Thomas Gleixner wrote:
> 
> > +typedef bool (*stack_trace_consume_fn)(void *cookie, unsigned long addr,
> > +                                      bool reliable);
> 
> > +void arch_stack_walk(stack_trace_consume_fn consume_entry, void *cookie,
> > +		     struct task_struct *task, struct pt_regs *regs);
> > +int arch_stack_walk_reliable(stack_trace_consume_fn consume_entry, void *cookie,
> > +			     struct task_struct *task);
> 
> This bugs me a little; ideally the _reliable() thing would not exists.
> 
> Thomas said that the existing __save_stack_trace_reliable() is different
> enough for the unification to be non-trivial, but maybe Josh can help
> out?
> 
> >From what I can see the biggest significant differences are:
> 
>  - it looks at the regs sets on the stack and for FP bails early
>  - bails for khreads and idle (after it does all the hard work!?!)
> 
> The first (FP checking for exceptions) should probably be reflected in
> consume_fn(.reliable) anyway -- although that would mean a lot of extra
> '?' entries where there are none today.
> 
> And the second (KTHREAD/IDLE) is something that the generic code can
> easily do before calling into the arch unwinder.

And looking at the powerpc version of it, that has even more interesting
extra checks in that function.

Thanks,

	tglx

