Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B37BC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:57:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 325DB217FA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:57:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 325DB217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D61846B0008; Thu, 18 Apr 2019 07:57:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D11256B000A; Thu, 18 Apr 2019 07:57:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD8866B000C; Thu, 18 Apr 2019 07:57:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4986B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:57:35 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id j63so1879469wmj.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 04:57:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=aKZXhFAE/6GwfdvgSKv/DRHNygA6b04edtuEuuBcJwU=;
        b=X8q71dMHR4HscXuNDFSErbAISnkORzAoZkXtDGRlBg0yEUlvXUwLY/SSOY1bA+ckuO
         UPhpBVZH8+jn9/oCJjEBM93jb3Nu7/I5fpcUjobA4sJl3LKGK7Fk8Y1vxwUMQ6R+aBTY
         o9uw6XA+lM69GfDc+q5onWJStKX4SGagjC7qOka+UPDQpbWacIFCii8B47OlsJYGiGrD
         G1lSgks5nDws5IZpmr5qGgXpP13qgu6HPV9rkmPf7xGoXOcyKutVA+at91yhLZFvTcBB
         bYrmNKEUtaoEXAa3QT+DxRcJGoNIoAb6QFhJK/5RlULvzpggIu7Lt+UXwoJAHaF6oVu6
         0lzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUlNx3jmLwb5g9n0qN4k1oUagR8ROYBfdOdchWGAq7A+VHVliOL
	HIbFXpz6g/jjmzlMMNQkXoXbnInZn9BlPxANSkp9vH1+rlhFuc3AQvL9J4igz386J+rJExX1PoZ
	FUQsJP63XwkdBJQBEJkunJAsTt3dB1m3HPV/qOvjyMx0WlSCDk8cA/FhRgxLXmx490g==
X-Received: by 2002:a1c:e912:: with SMTP id q18mr2758116wmc.137.1555588654982;
        Thu, 18 Apr 2019 04:57:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynxrkUA6ZqwQd1WxApfPXxKPYBB4CxYZvuqEwuO0BeH3DMrmDAkaEl9gv9w3Cd9wwR7Vp4
X-Received: by 2002:a1c:e912:: with SMTP id q18mr2758078wmc.137.1555588654219;
        Thu, 18 Apr 2019 04:57:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555588654; cv=none;
        d=google.com; s=arc-20160816;
        b=WJm/pwaMrLqBVNNy8KW6I8QgS8gmBEiyUQHmkaXzLvre093eOWjWuRzaW0bdXioTEI
         oJEWhi1+YdbGKx/K9Csyffd4Yue6pffX38sDXRoUp6Sv2/XnHdBRbiBHjESGLhtPQAHW
         f+2oXoTwKJihUoz5v5MkxTzfvFJXInoTQvhFKeiZ4RxCw6XK3CIdLP2kNZj6zumSGl1B
         TwWabtlBd0x81OBjiKXS/rYv1oW3KJkHSNm28b8lC7K6OTcOQzg0VRQNk5NScb4U9qnu
         jRWvgW3SfqcBVAUUL9KBKHKPpIMIwbIj69IHhJNpMPbcYCsNqFfXIpwWqFVy1P1nvc8l
         /sHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=aKZXhFAE/6GwfdvgSKv/DRHNygA6b04edtuEuuBcJwU=;
        b=HwKIRnWgWsEsvx0GJ+0rLgacoGaODxFc2ifx1SUBCbOxhpN6lz5l6SebOEi4qRdsBm
         B7M4jwH318+nD6q4T4pSt1MNqX7KpVrQAdyFQjPMi476hhZOS5s9wspmyHaXY875xqUL
         lFWgaqhYVH0K6U2HGE671mABS/svBcDRVgR4UsHgXs5Q61cDvKv6/2bKFa+uyi4Plx5y
         98BDDMK1mNfaBXk1QUokx7XjJu4mKWpBu+NTdzDUV3ccSdyIUNYw9EEEt5jCk3WvLprH
         XPRudqBDrAiV7NwUNvyUjHPWxEX2SYpwyrZN9337r/Ai/Lj+icqSaQ47IsExcA30GWPG
         pKXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v10si1519492wrt.101.2019.04.18.04.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 04:57:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH5fQ-00069B-K5; Thu, 18 Apr 2019 13:57:24 +0200
Date: Thu, 18 Apr 2019 13:57:22 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Mike Rapoport <rppt@linux.ibm.com>
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
In-Reply-To: <20190418115207.GB13304@rapoport-lnx>
Message-ID: <alpine.DEB.2.21.1904181355300.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de> <20190418084255.652003111@linutronix.de> <20190418115207.GB13304@rapoport-lnx>
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

On Thu, 18 Apr 2019, Mike Rapoport wrote:
> On Thu, Apr 18, 2019 at 10:41:47AM +0200, Thomas Gleixner wrote:
> > +/**
> > + * arch_stack_walk - Architecture specific function to walk the stack
> > +
> 
> Nit: no '*' at line beginning makes kernel-doc unhappy

Oops.

> > + * @consume_entry:	Callback which is invoked by the architecture code for
> > + *			each entry.
> > + * @cookie:		Caller supplied pointer which is handed back to
> > + *			@consume_entry
> > + * @task:		Pointer to a task struct, can be NULL
> > + * @regs:		Pointer to registers, can be NULL
> > + *
> > + * @task	@regs:
> > + * NULL		NULL	Stack trace from current
> > + * task		NULL	Stack trace from task (can be current)
> > + * NULL		regs	Stack trace starting on regs->stackpointer
> 
> This will render as a single line with 'make *docs'.
> Adding line separators makes this actually a table in the generated docs:
> 
>  * ============ ======= ============================================
>  * task		regs
>  * ============ ======= ============================================
>  * NULL		NULL	Stack trace from current
>  * task		NULL	Stack trace from task (can be current)
>  * NULL		regs	Stack trace starting on regs->stackpointer
>  * ============ ======= ============================================

Cute.

> > + * Returns number of entries stored.
> 
> Can you please s/Returns/Return:/ so that kernel-doc will recognize this as
> return section.
> 
> This is relevant for other comments below as well.

Sure.

Thanks for the free kernel doc course! :)

	tglx

