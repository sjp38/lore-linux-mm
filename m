Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7EF7C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:03:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B61020833
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:03:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Ros4p2hk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B61020833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAEC26B0005; Thu, 16 May 2019 13:03:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5F126B0006; Thu, 16 May 2019 13:03:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C259F6B0007; Thu, 16 May 2019 13:03:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABAC6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 13:03:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g38so2491163pgl.22
        for <linux-mm@kvack.org>; Thu, 16 May 2019 10:03:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=2OkSls3BBuVCd2Q9OzzUfEJIECS5yJPO8xcocfnTaN4=;
        b=cy/j+QF/XbDvXwUcbDZT7NgJ3UQkZVnuit0/CquDuf2AAWNzR4j7f5fbp3Stvb73pX
         ZziaQJhn06lgRweZEZwlFVnJYN66krAXGgHApr9u91AGR1qax3f/JK1BLY+ffC7UXrJL
         SAej4TeLyLrhWC1HuyJLBtAMwU2KN+KdrCeGYuY/VLYXXdg7ELQ/odMYS8DZ1HSQA/oJ
         5gXP25vQP0WUuKekrPgvv6KvG3xQTVJXmBzw45jrMRJy5KdztxKS/S7XaPbysEwLV1QK
         00p9QD3NgMyGfTdOp+twBTib8c2k55HolcN1ZXoc1QPlwkdD4duBLlHC/PtIuFqo1MDc
         KAWg==
X-Gm-Message-State: APjAAAXVgpp+Yg/1bhYHFne13+nUbVSF5o2Y7pA3LY1D0iG0tuOu6mH/
	wRUVjOGWI26ZYv0eg1wWuVFt0XqNPm5MrTOrQU6NHQnqpvn0HRg0xez3zlCssKCeygfF7meBgzp
	WPS8af55mVRdeQzOmdu2EOVUlS6On4PjzcOv4V9fUZNOly/oQ1X4TLOioq97kPvf84g==
X-Received: by 2002:a65:4c4c:: with SMTP id l12mr50784322pgr.404.1558026195085;
        Thu, 16 May 2019 10:03:15 -0700 (PDT)
X-Received: by 2002:a65:4c4c:: with SMTP id l12mr50784255pgr.404.1558026194223;
        Thu, 16 May 2019 10:03:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558026194; cv=none;
        d=google.com; s=arc-20160816;
        b=WS8gMyoHSSZfU6mCRmhjL/sxnFvHr2HsxKRKFPz7wVaq647FlcdheVv15MuejYeglS
         nzqnxG9Hd/W9siSqU9D/O0AC8I3RX9nq8WaG6mLf+x2CvdJuCk+J4W4E27V/GQDp2Cwo
         Ov+NbWeSaZeq+qhCWXGfnez3+Dn0IZHXcieLfdIBuphyR3rVqAOpHLq0Kz3bcBSmhmlW
         Iz3Pg+FE4BeSE4xXCgiKj2sJu/zuyIW3cYp8JDT0bJPK2fe4+dpTiZNP6xKli6e4ijSd
         Sr1xR3mzAqYv9S5PdJDWtFT84Q28Hf6ErFpXD3N/cQucZfHRbU6bWz7IyR7CuN2qo4Vd
         avHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=2OkSls3BBuVCd2Q9OzzUfEJIECS5yJPO8xcocfnTaN4=;
        b=bpY4atGVQ00MsNPzW2sXeDXHKHxoFMUysVrH0DAbvg500k80OBJcqhgtUteSTes2qB
         Deno+18LNEhf7VVgCd7jrKPhfwtd3wtnUp60fiFMAfwd0C2AVPrrT0573dlHwn5HtCrs
         HeAL1LU5LAz/1AGZqcmRmhm/uxSJ6iH53geKdYZD9IMqs1R49CaX255vtjIJKy3MNlpX
         eOjXNgq27XFvhcgdtkT3XDCOKT5d/cKRmIDvGuTcPE8AfP56dY9WXMn6kRL7NI9iMHaF
         0vNSn+uMv0tMTd+DHM+GJo4Y+VVy3og2pdluPmoTAtC5DrWbUAGRgLtgQtg9Dl7qNv7I
         VowA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Ros4p2hk;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t21sor6550455pfa.46.2019.05.16.10.03.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 10:03:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Ros4p2hk;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=2OkSls3BBuVCd2Q9OzzUfEJIECS5yJPO8xcocfnTaN4=;
        b=Ros4p2hkOqmoHbdixDDcfrW1H7jyK9zIQYjqlUFzXr5CiZP+1t7cTKrai4i8J8Q1Jc
         TzF8dMleKNk7RbmmoaakWyHRVMp2G/Ig5tkzDXUlXt800e0jwOfhD+WEBmHapdlbmP4M
         EBbEoq8OjOlQ/XJdZ16uZvhYu/dMHPBTDkc+c=
X-Google-Smtp-Source: APXvYqxf86X0I5LWFcSKWu+jd0qD6qpD2y7bXzGg9HBoYqsOh3qhcsFm36RFG3tU2Ws97h56kHXWnw==
X-Received: by 2002:aa7:9a8c:: with SMTP id w12mr54743779pfi.187.1558026193892;
        Thu, 16 May 2019 10:03:13 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id b3sm10386588pfr.146.2019.05.16.10.03.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 10:03:12 -0700 (PDT)
Date: Thu, 16 May 2019 10:03:11 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201905160953.903FD364BC@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-2-glider@google.com>
 <201905160907.92FAC880@keescook>
 <CAG_fn=VsJmyuEUYy16R_M5Hu2CX-PJkz9Kw4rdy9XUCAYHwV5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=VsJmyuEUYy16R_M5Hu2CX-PJkz9Kw4rdy9XUCAYHwV5g@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 06:42:37PM +0200, Alexander Potapenko wrote:
> I suspect the slowdown of init_on_free is bigger than that of
> PAX_SANITIZE_MEMORY, as we've set the goal to have fully zeroed memory
> at alloc time.
> If we want a mode that only wipes the user data upon free() but
> doesn't eliminate all uninit memory, then we can make it faster.

Yeah, I sent a separate email that discusses this a bit more.

I think the goals of init_on_alloc and init_on_free are likely a bit
different. Given init_on_alloc's much more cache-friendly performance,
I think that it's likely the right way forward for getting to fully zeroed
memory at alloc time. (Though I note that it already includes exclusions:
such tradeoffs won't be unique to init_on_free.)

init_on_free appears to give us similar coverage (but also reduces the
lifetime of unused data), but isn't cache-friendly so it looks to need
a lot more tuning/trade-offs. (Not that we shouldn't include it! It'll
just need a bit more care to be reasonable.)

> > +void __init report_meminit(void)
> > +{
> > +       const char *stack;
> > +
> > +       if (IS_ENABLED(CONFIG_INIT_STACK_ALL))
> > +               stack = "all";
> > +       else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL))
> > +               stack = "byref_all";
> > +       else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF))
> > +               stack = "byref";
> > +       else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_USER))
> > +               stack = "__user";
> > +       else
> > +               stack = "off";
> > +
> > +       /* Report memory auto-initialization states for this boot. */
> > +       pr_info("mem auto-init: stack:%s, heap alloc:%s, heap free:%s\n",
> > +               stack, want_init_on_alloc(GFP_KERNEL) ? "on" : "off",
> > +               want_init_on_free() ? "on" : "off");
> > +}
> >
> > To get a boot line like:
> >
> >         mem auto-init: stack:off, heap alloc:off, heap free:on
> For stack there's no binary on/off, as you can potentially build half
> of the kernel with stack instrumentation and another half without it.
> We could make the instrumentation insert a static global flag into
> each translation unit, but this won't give us any interesting info.

Well, yes, that's technically true, but I think reporting the kernel
config here would make sense. If someone intentionally bypasses the
stack auto-init for portions of the kernel, we can't meaningfully report
it here. There will be exceptions for stack auto-init and heap auto-init.

-- 
Kees Cook

