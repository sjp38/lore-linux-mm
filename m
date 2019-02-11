Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D371C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:41:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 408FC21B24
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:41:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 408FC21B24
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB0938E014B; Mon, 11 Feb 2019 14:41:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B60D08E014A; Mon, 11 Feb 2019 14:41:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A51318E014B; Mon, 11 Feb 2019 14:41:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3988E014A
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:41:25 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y85so9323wmc.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:41:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=c0VnHEFjMLoIiHt4so+WywZliSRyH8qj+HG/yNPWEQU=;
        b=A29fIo/X5bFTQVwFcbAHEbw/TO8efe59fEV47Efew4LR9/jz6WrjNx35qyEyA9LV/c
         PyXBc2irA0/P061UKC9fkvwrXexYHgwVGRCbBhj6qDUvcvY9mfNpVjcWMNqkE65WQc/6
         URflXxbyUdmwTSR2Td7zAh2ZpIz4z/DK+dmjYxNBIHW6Ts6zSX6DqUCkcznk8pa2gRfY
         X4kidNQkjCXA8hQ/j3gpQLIpH2LaRzy23r/lcDrbLIaYeRczQ41pFMKsToO8BwKZ4+YW
         uAetirneVIZXJCod1XIDQVqWX595Sn0X9vyA12fvEnV2nctLEE3k99oWZ6vLg024CShz
         rsgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: AHQUAubu3ynCcT6wdZt8H9KzlTNQcM5ryMk47u8Rlj5GBviv64nOerJs
	qWHhrvO+BLO7HdO0s2JZvPWStKsL61l1ktq3S5hjqg6noq43fgmwAgLCCihbh3eFP7rRL3+f16d
	efQIxj3x107+xJlTn4YRAnx3MkaIiq+I/ckGFsNEJrqvL7wl5ZaDNoZ4PesYpyJtfwQ==
X-Received: by 2002:adf:b783:: with SMTP id s3mr30126552wre.274.1549914084822;
        Mon, 11 Feb 2019 11:41:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia5xjw7So9G6sO7rs9tW2/Sb9+kRQXJdlnux4qMAw4e3XmB3oIf5XkxmW4UXc/XGgecWkUe
X-Received: by 2002:adf:b783:: with SMTP id s3mr30126513wre.274.1549914084017;
        Mon, 11 Feb 2019 11:41:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549914084; cv=none;
        d=google.com; s=arc-20160816;
        b=B/etDE8jmuoGAE4k4KCw+7dggSrei87rQYdSmbACeDz/cK+k5U7JKmABjAQ7jpM9N7
         kkTh3UMgtlykW7Z7ljAGga6dcGR7LtmQ1vPWEsHq/Cb/4XdZSDfQ4lFfLwjRmAOrltGk
         B1CcTfofyJ6/x8ZybQosguAq1oOuHDoQx+UOOh4bGYHwzSG174Jbs3/8CDbwhUY+iEmd
         kimTlqcb2KrIyLKVBcNd7LXTb4zhYCzTOcJ+eJJ7f5RreIXD7UUvQG/fKLY52Mhb6ZGp
         mwMncMdCPHaOBLRIZGnOF/HU5z2PEp37Mo3ELSt6roVsuHANw590XtM+r5ZXL3jaAtrq
         /eTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=c0VnHEFjMLoIiHt4so+WywZliSRyH8qj+HG/yNPWEQU=;
        b=ZC/f1X8guxVUeAMVJcw7fVoKfGpDMQiVSoHEI1DSc15N1UZeXF48jzYNjpS2AlpXuS
         dlXRbc9qvW9IJ70KzJvcesp9LT7aFKNkbvfxh+lpFrxViVDIvo4lUOjfLkw6gmwclGTE
         3JHwmmZWoO3eLmSID0UwlBHrHmgXpUk6Ed52eqd7teay8c9JjB1ctynCE3IiMJZB3Ga+
         oltQVBv3BgSClCsiXvPkxOD3PuWyjIIb98EvlZ695xkGTAl5J7DdDSi5eYcEnYITjAnN
         cNCJc3d19mUvln6VSjmKzkjwBr4Iuuow/FLCSGf1TZXKCrpnmw0mA2tHRQlEe5zBoQEs
         iyIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 1si8479358wrp.24.2019.02.11.11.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 11 Feb 2019 11:41:24 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1gtHRu-0001dx-Sc; Mon, 11 Feb 2019 20:41:03 +0100
Date: Mon, 11 Feb 2019 20:41:02 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190211194102.3uvqjpfoez4cvgq6@linutronix.de>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
 <20190211185318.GA13953@cmpxchg.org>
 <20190211191345.lmh4kupxyta5fpja@linutronix.de>
 <20190211191745.GH12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190211191745.GH12668@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-02-11 11:17:45 [-0800], Matthew Wilcox wrote:
> On Mon, Feb 11, 2019 at 08:13:45PM +0100, Sebastian Andrzej Siewior wrote:
> > On 2019-02-11 13:53:18 [-0500], Johannes Weiner wrote:
> > > I'm not against checking for the lock, but if IRQs aren't disabled,
> > > what ensures __mod_lruvec_state() is safe?
> > 
> > how do you define safe? I've been looking for dependencies of
> > __mod_lruvec_state() but found only that the lock is held during the RMW
> > operation with WORKINGSET_NODES idx.
> > 
> > >                                            I'm guessing it's because
> > > preemption is disabled and irq handlers are punted to process context.
> > preemption is enabled and IRQ are processed in forced-threaded mode.
> > 
> > > That said, it seems weird to me that
> > > 
> > > 	spin_lock_irqsave();
> > > 	BUG_ON(!irqs_disabled());
> > > 	spin_unlock_irqrestore();
> > > 
> > > would trigger. Wouldn't it make sense to have a raw_irqs_disabled() or
> > > something and keep the irqs_disabled() abstraction layer intact?
> > 
> > maybe if I know why interrupts should be disabled in the first place.
> > The ->i_pages lock is never acquired with disabled interrupts so it
> > should be safe to proceed as-is. Should there be a spot in -RT where the
> > lock is acquired with disabled interrupts then lockdep would scream. And
> > then we would have to decide to either move everything raw_ locks (and
> > live with the consequences) or avoid acquiring the lock with disabled
> > interrupts.
> 
> I think you mean 'the i_pages lock is never acquired with interrupts
> enabled".  Lockdep would scream if it were -- you'd be in a situation
> where an interrupt handler which acquired the i_pages lock could deadlock
> against you.
With RT enabled the i_pages lock is always acquired with interrupts
enabled because spin_lock_irq() does not disable interrupts.

Sebastian

