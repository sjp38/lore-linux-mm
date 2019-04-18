Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0D0BC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:53:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A748D2183F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:53:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A748D2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3517D6B0010; Thu, 18 Apr 2019 07:53:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3278F6B0266; Thu, 18 Apr 2019 07:53:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2188A6B0269; Thu, 18 Apr 2019 07:53:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB8F76B0010
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:53:36 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id f12so1778980wmj.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 04:53:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=y3PXhLtNUtfy8g0a1vUfshuhGXPYHwQKkE/mVrJEBZI=;
        b=R5kwf9fsAVRjSmu32GURC0n5OgajxpCxFFbFY6ULQC4ddQRU1KDO9BOkHaTm1awdg+
         iIhsp34nsPGN0ugWsLMFicuLBv/Kv3bAaq5cdS5a78ulkXwdNwIvWX4sYXlUMxthxjVd
         AFhsECuciUtEP8vg1Zt2mCrX4WLqd8JTttiqhWLUVRNFegJBPxPBarU2EnZJBaCCeq1I
         IidoC7vY7XlytRhw489pSEbMadaGh15CbJDsC7kqQGZ7fXRlodCiWhwwSi37FuDwW8Eq
         RJ1CP0hYN3fykK9DQSyZE9XwXqo+qAXxScLfsuoZvLOjwubtBGt6vQnOregq8gg8m9cI
         Vokw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVDXL5Yt7Pe81CSt/2lwxQxhTmvUNiAVAxfYQO1R315MEIy6QwK
	1JVCdpdy9xuIIO6tQ8DWMMfykSUQpdHoYxjyEPewD8LMlHuterAlluX7hWTVtoS820AJ7Yjep2t
	10nbghMTxtb73sLDLUyoUqQtY7PtCBVWeFQizVgQWMffjsi+ZY0XiRizUqCrNZbD8Iw==
X-Received: by 2002:adf:df0f:: with SMTP id y15mr41675376wrl.175.1555588416365;
        Thu, 18 Apr 2019 04:53:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcHsScjO0Qu0ueeilDsEG6l74lUsBJK3lKJYqLugKJxtOMV0r3HnlWZq05+EWcMR9inSMd
X-Received: by 2002:adf:df0f:: with SMTP id y15mr41675325wrl.175.1555588415545;
        Thu, 18 Apr 2019 04:53:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555588415; cv=none;
        d=google.com; s=arc-20160816;
        b=M1/OXVcAQcy0HhUgKqbTOkVDqTULL009BjyJt8pukiE7DvCVH4vg8UE7iB+Cz+vN7/
         avTCj3RqqZEby8DZ3TWCO6z3cAUcI7k3Bkkpc1FDPkWbIdJeNMCAtv62p2kWs1OqYuml
         0S/B9wWZmU2UD6Mr3V0VR2poByjfDjXUG5WlzBaBAYanU2nwi+DYdvJloO+TAjw+swfw
         0BOaX9z2ooYWnbc0jYBgqIc4JRL08WnG6XCB+M6F0rBEQLZ7eYCNnD4N+WXqsr5z3CCd
         Q2LXwivvrafzEcJo+8MQf4pPlCgsbyEkn2CH6hBg7a/VoO6dglyi2II+ZKytcAKR+kS1
         v6YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=y3PXhLtNUtfy8g0a1vUfshuhGXPYHwQKkE/mVrJEBZI=;
        b=ea+ZFQgS7rLxztwqD2e40SBH7GzAaodLgOQzpUAbn5o4xJZSB6HjSrpVv55wzbI/6I
         KRxc4pFJQw0OuCyP2B5owlt2iICBQX7FFOMB2tElsm+DnP+QKhWFzfOggpiJ+Pk/RNtU
         JCYBDz8X6oDZzRLeuA4TaNi3QYR31I55H4EHnGHPkeaTLr9aQlO4FCyBcnj67kNohnsW
         +t85bdNlicHqIO49+MSvbmJPTuhCU+z/zJ6b3jrq75YGFk7qA7igwWYP8EEJa9lJCjmY
         xDC2i7G7LTR21APl2J688kMdI6zfk3XKYHnN0Hi/zD91iVtOLVrXaSTxB8vO4hLu86U/
         KLhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h16si1144741wrm.206.2019.04.18.04.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 04:53:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH5bc-000615-N4; Thu, 18 Apr 2019 13:53:28 +0200
Date: Thu, 18 Apr 2019 13:53:26 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    x86@kernel.org, Andy Lutomirski <luto@kernel.org>, 
    Steven Rostedt <rostedt@goodmis.org>, 
    Alexander Potapenko <glider@google.com>, 
    Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, 
    linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Christoph Lameter <cl@linux.com>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
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
Subject: Re: [patch V2 09/29] mm/kasan: Simplify stacktrace handling
In-Reply-To: <5b77992a-52b6-807e-f77d-9cf3e648c71f@virtuozzo.com>
Message-ID: <alpine.DEB.2.21.1904181350080.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de> <20190418084253.903603121@linutronix.de> <5b77992a-52b6-807e-f77d-9cf3e648c71f@virtuozzo.com>
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

On Thu, 18 Apr 2019, Andrey Ryabinin wrote:
> On 4/18/19 11:41 AM, Thomas Gleixner wrote:
> > Replace the indirection through struct stack_trace by using the storage
> > array based interfaces.
> > 
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> > Acked-by: Dmitry Vyukov <dvyukov@google.com>
> > Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > Cc: Alexander Potapenko <glider@google.com>
> > Cc: kasan-dev@googlegroups.com
> > Cc: linux-mm@kvack.org
> 
> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> 
> >  
> >  static inline depot_stack_handle_t save_stack(gfp_t flags)
> >  {
> >  	unsigned long entries[KASAN_STACK_DEPTH];
> > -	struct stack_trace trace = {
> > -		.nr_entries = 0,
> > -		.entries = entries,
> > -		.max_entries = KASAN_STACK_DEPTH,
> > -		.skip = 0
> > -	};
> > +	unsigned int nr_entries;
> >  
> > -	save_stack_trace(&trace);
> > -	filter_irq_stacks(&trace);
> > -
> > -	return depot_save_stack(&trace, flags);
> > +	nr_entries = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
> > +	nr_entries = filter_irq_stacks(entries, nr_entries);
> > +	return stack_depot_save(entries, nr_entries, flags);
> 
> Suggestion for further improvement:
> 
> stack_trace_save() shouldn't unwind beyond irq entry point so we wouldn't
> need filter_irq_stacks().  Probably all call sites doesn't care about
> random stack above irq entry point, so it doesn't make sense to spend
> resources on unwinding non-irq stack from interrupt first an filtering
> out it later.

There are users which care about the full trace.

Once we have cleaned up the whole architeture side, we can add core side
filtering which allows to

   1) replace the 'skip number of entries at the beginning

   2) stop the trace when it reaches a certain point

Right now, I don't want to change any of this until the whole mess is
consolidated.

Thanks,

	tglx



