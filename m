Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3264C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:43:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7E94217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:43:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7E94217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B1316B0269; Thu, 18 Apr 2019 11:43:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 563066B026A; Thu, 18 Apr 2019 11:43:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4520A6B026B; Thu, 18 Apr 2019 11:43:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED6246B0269
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:43:10 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u6so2209589wml.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:43:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=U8s7AoQ/InpTaiomTRXjsIO3Vv1z7SjMxyh0o9DPMBQ=;
        b=qHwHCti6eBnJ0lpgypg+Ra97gztOO6SFV/FUJ7r1OvneLI4cjcaqJoxm2cmSPk/ebf
         K6FGaoS3DplhQGS7WN1+6tzu1o+Ft6FU5Km9ZrX2Md45DQJPmN0cgbqOMzWKEQKv4t7g
         P0rZSCIo4nGXws/h5l49maeDJWFqM2Ux9cAbiXFX9FlzzqevvkfH1MRbe46++oVY644N
         g3ccyC5K/yYQCwQnDfurpd1MoLR36rMpEa6IcMcMO+m25zWWM8NQdnoPW2+0zPeAs4lj
         snEc0+BWpe8l38xFbGvYTayJIjA723UUU3XQuZtKh1h5U4GzIuxwEcHOI+cnVxEjN3Ef
         vd+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXPvWjT9XRgvvzAw6IZX0F5o5L6IyAAIAufqZBozQ0qaWe0q/Xw
	3hhHi8mSuLT30V9FXgedLXAHJhVYtxLRtpOyfIB7L5S7gDXCtvkhrrJL9RtqTFjaDiMluq6PAjl
	Eh8GGeAB45Mk97GjfEKNQIq21zvQXb1P92T/TmX01H99g6+Tp/TEnz//vqetDwHwatQ==
X-Received: by 2002:a1c:9cd1:: with SMTP id f200mr3528251wme.91.1555602190455;
        Thu, 18 Apr 2019 08:43:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxM/pgiTO5n+hM/80InsPSILAVpofdZGUE4tRcHzTUk6jlae13bK7xq1IzwCr8Fc4M6kwvm
X-Received: by 2002:a1c:9cd1:: with SMTP id f200mr3528203wme.91.1555602189539;
        Thu, 18 Apr 2019 08:43:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602189; cv=none;
        d=google.com; s=arc-20160816;
        b=pqsd+7X3jgZyf6lyWSemjiBJA7B0UA1VyYwvXrqGqYlTWQiRdI9uX4jjO4+G3sH3RT
         mOZeAjUIojxvSWK3VHnIRi++INhF+MPzxPOB9CfKIDCQ8BNfqZdLNZpff0PrpLNl2SLh
         zr69QzOv8JoXYUb/DLhwyRWaaLtWJKJdfmQubIgC8r7yoxvTMdW4ikxNrdJVXiG+3S+D
         CKxl5SY8Nfq5mPuuVzIbWbInE/ImnAsKoznafM6oZ8PSvsWXMSaukTW9g9+2xIlmzfAr
         QaPd/ikNUWk3qV5FXR/YiSS9cCSX8jvnkVAY77sCrCLz1enqR6B9uPqLf6TF0uOUpYWs
         AdtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=U8s7AoQ/InpTaiomTRXjsIO3Vv1z7SjMxyh0o9DPMBQ=;
        b=DcMAGpiMO4IGvUT/bQQErCj2ImHsxopPcn+RpI0SBJQZ3kw6IxvLrUfNY0VCuI0jYC
         Gno45g/j341u5tPhTV6Re/xsBv2kuMBdHYa1aPUeG/yMzjXq+/I+oVxAflJbxpvcqz97
         Tay2+4AlzJl8dZWs72gjFAYh++dbN29hhiDJdeKn9xAWhzlp8Od9dkLoxVKCTTA1sw92
         0b1xDE6nuKSvKZfcN72kXkkAPRdd1J2C/FCu7emBHJtQJN3LsKAmqkO9ONjUTU7vQnzL
         tRN/Cmr8l/YHmheHHDpLt3rAIEvy+YrSbWvU6Cq5/jkRR9Az+Vl4iYiFIsDY06PZANd/
         hjhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v13si1946168wrp.115.2019.04.18.08.43.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 08:43:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH9Bh-0004nI-GJ; Thu, 18 Apr 2019 17:42:57 +0200
Date: Thu, 18 Apr 2019 17:42:55 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Josh Poimboeuf <jpoimboe@redhat.com>
cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, 
    Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 
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
In-Reply-To: <20190418145201.mjzyqbmkjcghqzex@treble>
Message-ID: <alpine.DEB.2.21.1904181734200.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de> <20190418084255.652003111@linutronix.de> <20190418145201.mjzyqbmkjcghqzex@treble>
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

On Thu, 18 Apr 2019, Josh Poimboeuf wrote:

> On Thu, Apr 18, 2019 at 10:41:47AM +0200, Thomas Gleixner wrote:
> > All architectures which support stacktrace carry duplicated code and
> > do the stack storage and filtering at the architecture side.
> > 
> > Provide a consolidated interface with a callback function for consuming the
> > stack entries provided by the architecture specific stack walker. This
> > removes lots of duplicated code and allows to implement better filtering
> > than 'skip number of entries' in the future without touching any
> > architecture specific code.
> > 
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> > Cc: linux-arch@vger.kernel.org
> 
> This is a step in the right direction, especially if it allows us to get
> rid of the 'skip' stuff.  But I'm not crazy about the callbacks.
> 
> Another idea I had (but never got a chance to work on) was to extend the
> x86 unwind interface to all arches.  So instead of the callbacks, each
> arch would implement something like this API:
> 
> 
> struct unwind_state state;
> 
> void unwind_start(struct unwind_state *state, struct task_struct *task,
> 		  struct pt_regs *regs, unsigned long *first_frame);
> 
> bool unwind_next_frame(struct unwind_state *state);
> 
> inline bool unwind_done(struct unwind_state *state);
> 
> 
> Not only would it avoid the callbacks (which is a nice benefit already),
> it would also allow the interfaces to be used outside of the
> stack_trace_*() interfaces.  That would come in handy in cases like the
> ftrace stack tracer code, which needs more than the stack_trace_*() API
> can give.

I surely thought about that, but after staring at all incarnations of
arch/*/stacktrace.c I just gave up.

Aside of that quite some archs already have callback based unwinders
because they use them for more than stacktracing and just have a single
implementation of that loop.

I'm fine either way. We can start with x86 and then let archs convert over
their stuff, but I wouldn't hold my breath that this will be completed in
the forseeable future.

> Of course, this may be more work than what you thought you signed up for
> ;-)

I did not sign up for anything. I tripped over that mess by accident and me
being me hated it strong enough to give it at least an initial steam blast.

Thanks,

	tglx
	

