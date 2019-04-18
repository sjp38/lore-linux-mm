Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11D6DC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD7EC2083D
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:44:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD7EC2083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6295E6B0007; Thu, 18 Apr 2019 11:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B05B6B0008; Thu, 18 Apr 2019 11:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 451B06B000A; Thu, 18 Apr 2019 11:44:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id E75846B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:44:05 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id k81so2221422wmf.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:44:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=T85dtROnmF3LaZ9WUs7vnZ//4A4b6xr0uFBWAp049/c=;
        b=neMb0OCcSuJctOr8aV3P7sKFg0363wGcCZgAEoCwdSjlckMoakpIwqEhz5N4REWyMt
         ZlivCeISON5gAI/lsX9xqkbBWeYdy5Eny5cfA2utRkFAoReYPwWLHeTv8ARCyuepfBlo
         5hsZIWFHFMJA2q+IIAiE0TPFL0fQwvSJgHuPne+TBidN2Ski69SW5/iI8s7psFkFUmK8
         n1ZLiOjutIT8SZHHFSM543oQy4A7IFqbODreHZg9Lypr8I9hOLnVt5MDPJs/zSJdos3A
         keg5z/NJKPThCByRPkQaYUIUSxY/F5RNt+FxgKupZAEQRpewBFhocL9wAbyTpGtkyU0+
         W5MA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAW7RzBMsv16W5JT5YXBvD8Oy92EvrB4Xsz+nFc9+av9akVcQ23d
	A+nCAOuH3flDPxWmTXkqmHksacICJisoDE+J2Ko29aSrpZVX1Vgetu8e7Eol1NKOC8aPsqEprKg
	QwVQ5n09kq4m0rV01IODzlx8F9mEiHwXLa2KTNEWZjlJdnxGuqTAuryulIDnbWXPmNw==
X-Received: by 2002:adf:8bc5:: with SMTP id w5mr58351480wra.226.1555602245488;
        Thu, 18 Apr 2019 08:44:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7FUCzLyJNhbdRYNRyNXZFSDBpYNl8Jhsn/EPcgCSw7u21VHVtPKYObocDmLAVkhflWteH
X-Received: by 2002:adf:8bc5:: with SMTP id w5mr58351434wra.226.1555602244860;
        Thu, 18 Apr 2019 08:44:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602244; cv=none;
        d=google.com; s=arc-20160816;
        b=ht7Vh2bR7M+VfO1reThjUGAOXM6abe00FjZtVE5zs4ZJopxYJLjqsQnWqbrFYG5kjj
         mQRp6vWY6rJXM8CjUwZmkWd6mEABOtD515Lv1apLc1B49wq4AfNNXl+cQvEh008Hg9Ky
         kN+aHLs1l8gq2tZVdvKfQW2jtpGfTm2d4iLqUwaDppC7dkrgmOyPPxNWBo/qjl/urh7v
         uQlvkAotH5Anx044ynW7pAv8+hszlSv6VikIjXM1FjpiSOsX3uinknVKdtMM1oCwfPIW
         7wGFApW5mG6PwNEP1OThscxT2aqcgVyI1rOCng1rNhanwJFN9wO5NNSNLMiyu0QI2eti
         rwHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=T85dtROnmF3LaZ9WUs7vnZ//4A4b6xr0uFBWAp049/c=;
        b=hy4NoUU2HjnUh8WrZR2zE534iS8WqoqUfK3GdiXIp7Aki+T/Ay26ePUsPPVZzHOqTU
         evZ9X7US2KoLnIxqPlPKC0ywq0whw+dJBhRprisAfnzy6+LNmJ/fd41t8ECIs5liyp6A
         gYtk3Kt7Iw2dSzEBKCBYvRgb8YqGmnPTCmTKxHKFQULl3OQGXgiSMyVf4NqRY9awx6+W
         cRAU2DWIb+9TmtDcLfgCQex3F/30rcGs0I7bWHAZI/SHmZ/JQttf9yMotwGXAeHunKNo
         RMlrX+hwGUHNp0vhsQzfcRCvgXtVz7X7wz/S9hvNIwPT+F+jxTatgK2rgIgXXg1iAR4n
         /Pzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x184si1761951wmg.6.2019.04.18.08.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 08:44:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH9Cj-0004qZ-CV; Thu, 18 Apr 2019 17:44:01 +0200
Date: Thu, 18 Apr 2019 17:43:59 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Steven Rostedt <rostedt@goodmis.org>
cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    x86@kernel.org, Andy Lutomirski <luto@kernel.org>, 
    Alexander Potapenko <glider@google.com>, 
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
    Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 21/29] tracing: Use percpu stack trace buffer more
 intelligently
In-Reply-To: <20190418105334.5093528d@gandalf.local.home>
Message-ID: <alpine.DEB.2.21.1904181743270.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de>        <20190418084254.999521114@linutronix.de> <20190418105334.5093528d@gandalf.local.home>
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

On Thu, 18 Apr 2019, Steven Rostedt wrote:
> On Thu, 18 Apr 2019 10:41:40 +0200
> Thomas Gleixner <tglx@linutronix.de> wrote:
> > -static DEFINE_PER_CPU(struct ftrace_stack, ftrace_stack);
> > +/* This allows 8 level nesting which is plenty */
> 
> Can we make this 4 level nesting and increase the size? (I can see us
> going more than 64 deep, kernel developers never cease to amaze me ;-)
> That's all we need:
> 
>  Context: Normal, softirq, irq, NMI
> 
> Is there any other way to nest?

Not that I know, but you are the tracer dude :)

Thanks,

	tglx

