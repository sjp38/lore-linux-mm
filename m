Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA906C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:20:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4941520815
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:20:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="OqrofeOS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4941520815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A98A56B0005; Thu, 16 May 2019 12:20:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A494C6B0006; Thu, 16 May 2019 12:20:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 937B16B0007; Thu, 16 May 2019 12:20:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF1D6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 12:20:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o1so2445184pgv.15
        for <linux-mm@kvack.org>; Thu, 16 May 2019 09:20:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=yP0cE4pkGcJKdZW9ZXRUC1LKbWz6dsrqiIXXwI8zTkw=;
        b=cV8/dfqzknF0L4pfVv+STOk5MgIbNlxG6TMV2eskkeLWrfCUqxOGiwqDbcbn6QfkQ5
         FAYE4RVtc68r/ir1lqae7HU4iZa7uyQFZHhSqxNH9DoMT+5687RTR9ic/NUqG6qdyLGq
         5himFG6n98NZQyTmnCgXK05AX6UqIzB1CrFYGKfIXS8mbQ+MuOygt3qBjoXm3qqChL1U
         cDnzg5imAHcEMfEqdLC8igkjYdya/5lCYE9rDGsMH7nDaK4MGQCXAa0uqbqpYJtM2Pf3
         SOEGEcKeyTBMsAh+MRfiwRZf+l34gtBPIHN6xUcPV5BcUklKH8Jwn2C+YpapOOcnsWJE
         zFog==
X-Gm-Message-State: APjAAAUnPYzOLsvdM0m384+r0bL2Af+0yd4xh4YV+pwCoJpxI4TGjZXc
	S+HB1C1GpYc/HAaVlorXdDVYijJ+Z+Wr6mQFRRE8yGbI5me0cVCbtrPrcTDPpDW0e0lEwn1hwtF
	otlvw6aTFECIyao/4R2LUp9wHPytwOapd8G7bzJDCjmksHBtRkLVmlTECYTG88NPR5Q==
X-Received: by 2002:aa7:8e55:: with SMTP id d21mr54644471pfr.62.1558023600783;
        Thu, 16 May 2019 09:20:00 -0700 (PDT)
X-Received: by 2002:aa7:8e55:: with SMTP id d21mr54644376pfr.62.1558023599721;
        Thu, 16 May 2019 09:19:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558023599; cv=none;
        d=google.com; s=arc-20160816;
        b=qXbclV88jeKYgYwupWXd89piIEaO4dyannEO6AyhKEORrUczdEMpuTrsIO/+b/3LA+
         V6LWg3/WE88w1ZE+1BdoZqntbjRUn7cOa/4FlsCaf8IQPhQgFNIFsux2qk6iqSSrSm3/
         wK/TMQwQqL+4FzfeYA5hrGe/KK3+ir7f1pTLlCeduohiTa8EUZCXdolmUzrzQZkhwhDP
         fbmRIywWty1tombNaTFnnpGgmxWvMPHlPL0r9G0rDVXma895oGfoDR6c+ZJYOKD6uYF1
         B0C6nZxLCvE2MW5/ffG2B71OHpM0bumSZf798CVmyhUYHWx3YrscAWNBMLL/hqUW4OiN
         A/Sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=yP0cE4pkGcJKdZW9ZXRUC1LKbWz6dsrqiIXXwI8zTkw=;
        b=nk0phBi3LXVWTa3iPMr8GkaNCL0MbiP5dk8XAA5oPRYzpaBaNhS58Jjh1tA8noo5ff
         cRef2XqrtdH8xwXgqg9sWy941xEYJlSnFKC9DwYEZUd688kWrEQU9yFlzIe8xj2l/HIU
         xHFuT7E7UC2dsEed6m3qmcUTQCBO1TAkk0y9cBQzmGrAvLbM8yazImPfjIGkGs6dDmI/
         GD0wdZdARN41xtTcggYEkkVSaeK1aXCDokGTH8FTAXeOEJguyCZUnHVQgst2NhxtZmGh
         nlQfVTq3meu05vHAFyNr29Iy/W5F60yObdFcRskc4bTNcAh8WbPP7Lx8dlY+pfAwgmGu
         ng1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OqrofeOS;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b91sor6557511plb.0.2019.05.16.09.19.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 09:19:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OqrofeOS;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=yP0cE4pkGcJKdZW9ZXRUC1LKbWz6dsrqiIXXwI8zTkw=;
        b=OqrofeOSP4xGgbSa919UicUmiJIY7a17QopQmpjZGC12Qp2G0pFiBpicR3AMAuhKAI
         r7C0WU5Smn/UMH1Klt5YhfyIJC7Qjd/AJx7o7zjf/xdnrpP9CXJuO/CXymY3Fqd6uCMm
         If0iGWx2csNJG0uAl7NIatFjqgY/SrMySeC4k=
X-Google-Smtp-Source: APXvYqwwdVxU3RArLVptXXf5WDtbyUwQfbfyfrx6F7sflsYNsu9rOlPCdFs7Ea9DF7EOfykQSK+7Lw==
X-Received: by 2002:a17:902:8c82:: with SMTP id t2mr43276568plo.256.1558023599081;
        Thu, 16 May 2019 09:19:59 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id s72sm7007143pgc.65.2019.05.16.09.19.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 09:19:58 -0700 (PDT)
Date: Thu, 16 May 2019 09:19:56 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: akpm@linux-foundation.org, cl@linux.com,
	kernel-hardening@lists.openwall.com,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201905160907.92FAC880@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-2-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514143537.10435-2-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 04:35:34PM +0200, Alexander Potapenko wrote:
> Slowdown for the new features compared to init_on_free=0,
> init_on_alloc=0:
> 
> hackbench, init_on_free=1:  +7.62% sys time (st.err 0.74%)
> hackbench, init_on_alloc=1: +7.75% sys time (st.err 2.14%)

I wonder if the patch series should be reorganized to introduce
__GFP_NO_AUTOINIT first, so that when the commit with benchmarks appears,
we get the "final" numbers...

> Linux build with -j12, init_on_free=1:  +8.38% wall time (st.err 0.39%)
> Linux build with -j12, init_on_free=1:  +24.42% sys time (st.err 0.52%)
> Linux build with -j12, init_on_alloc=1: -0.13% wall time (st.err 0.42%)
> Linux build with -j12, init_on_alloc=1: +0.57% sys time (st.err 0.40%)

I'm working on reproducing these benchmarks. I'd really like to narrow
down the +24% number here. But it does 

> The slowdown for init_on_free=0, init_on_alloc=0 compared to the
> baseline is within the standard error.

I think the use of static keys here is really great: this is available
by default for anyone that wants to turn it on.

I'm thinking, given the configuable nature of this, it'd be worth adding
a little more detail at boot time. I think maybe a separate patch could
be added to describe the kernel's memory auto-initialization features,
and add something like this to mm_init():

+void __init report_meminit(void)
+{
+	const char *stack;
+
+	if (IS_ENABLED(CONFIG_INIT_STACK_ALL))
+		stack = "all";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL))
+		stack = "byref_all";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF))
+		stack = "byref";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_USER))
+		stack = "__user";
+	else
+		stack = "off";
+
+	/* Report memory auto-initialization states for this boot. */
+	pr_info("mem auto-init: stack:%s, heap alloc:%s, heap free:%s\n",
+		stack, want_init_on_alloc(GFP_KERNEL) ? "on" : "off",
+		want_init_on_free() ? "on" : "off");
+}

To get a boot line like:

	mem auto-init: stack:off, heap alloc:off, heap free:on

And one other thought I had was that in the init_on_free=1 case, there is
a large pause at boot while memory is being cleared. I think it'd be handy
to include a comment about that, just to keep people from being surprised:

diff --git a/init/main.c b/init/main.c
index cf0c3948ce0e..aea278392338 100644
--- a/init/main.c
+++ b/init/main.c
@@ -529,6 +529,8 @@ static void __init mm_init(void)
 	 * bigger than MAX_ORDER unless SPARSEMEM.
 	 */
 	page_ext_init_flatmem();
+	if (want_init_on_free())
+		pr_info("Clearing system memory ...\n");
 	mem_init();
 	kmem_cache_init();
 	pgtable_init();

Beyond these thoughts, I think this series is in good shape.

Andrew (or anyone else) do you have any concerns about this?

-- 
Kees Cook

