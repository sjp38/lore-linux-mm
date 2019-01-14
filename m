Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26151C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 13:24:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4F2220659
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 13:24:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="M0gahmUK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4F2220659
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 640CA8E0007; Mon, 14 Jan 2019 08:24:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EF128E0002; Mon, 14 Jan 2019 08:24:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E00D8E0007; Mon, 14 Jan 2019 08:24:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2568E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:24:17 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s5so19693407iom.22
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 05:24:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BszPOXukd/CRgTGG7KPUfaCo5gW2bXdM+YoCchVA5ec=;
        b=gb7v8cTeiXKH/9Ju7A2LoU/lsbWn0UNLBBDID4yc+GJdBkjo2/CsCnHA+u4SxtgA4H
         lXIhNI5dU9XxVDSY8fCkuVZbTFSYoCNnG1Qzjkjv8kSMQEzvUhXddEsreER/c2b47DHE
         9t2ql03b44sst2eqMzO1RrSGBoctYVoupqhDe0SVD9XnlMkj/LXZ6cZBzkmLijBfbUJg
         e17YUmSynkWDLn9LmEHrxCXbgU8uuLx/3BCSDMZySmqU3GeRa4tvNlWg7EIpIzdU+2kV
         aBKUnL0tEiHv3syyCiY9OLN/XAyq/tJBA1CxKK8VNYx1GwcOtZ+kjrF4IONxNjdQ+eb2
         2ZXA==
X-Gm-Message-State: AJcUukda2j8RYAjC2upUB/hfSQb7SULiI+i99phKvySTf0iFVRGSo+QJ
	XWehMJyi2DDVwvV/8n8RQu/+K+7M3iPX+mJm4c+bK2GaltMkP8CekXow2cJ995l4h2Q24Qz9Z/n
	baiGtcvf/57vF10ZHeM8PM0KCXS4c+JO1g3/M/gvukLrIzSVGp0C/QA2fVK5Kgu2Q1ZHTuaWzhR
	eFRr0i1AGWj8XfaAd8f/toZyCq4/h7vYzEOomsVIvkdmIJAcsZ4/5StNsTUDhgGfvviEfQi/NqB
	W/wMBRi+hO5KfAnyD0YIDX7qPkZ45cBH7194SGQyFS2oec5Z1M8sOktLUew0yf5OYwGI8CRzCv/
	39ySOjEBlVgYc2h7Y7te3fqDs7ve8Pg0T1NG8yzC2TiMC5SnZj4PaJo4dVROsYpfxVJTcJDMk9k
	G
X-Received: by 2002:a24:6e14:: with SMTP id w20mr7826657itc.69.1547472256783;
        Mon, 14 Jan 2019 05:24:16 -0800 (PST)
X-Received: by 2002:a24:6e14:: with SMTP id w20mr7826608itc.69.1547472255609;
        Mon, 14 Jan 2019 05:24:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547472255; cv=none;
        d=google.com; s=arc-20160816;
        b=NdQzLt/ZDe5TXlDeLAKTGE8Hg2/VW+tMcNm2n6KMX2e699N9w+P8b58yibHkdeReGH
         zUtOKF//uyJrwRNBpwqbiySLflHka73nSs0f6XhNyn92Hu13VtVh/Ip/QNVnaOZHihvG
         qOj845ziRs6rjsdR+eMgN6OEe4cpzd+YEQ+Ha2Ynh3zgiRTRk5FBuNW9PnhHVCVIZ6ca
         oSqSXgjcfm+2Vm/vSXGv+DM30PejyJhLv6jLe+rQzUufn6WlO9+Y+UKY1zv2t5csf38A
         cLLOd+5s4Y7tNDyGWo2pT5pqF+M96nw4+71gsKyUTycqM7xSs9D5yOOn6bE9Ws93Ds2b
         Xgvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BszPOXukd/CRgTGG7KPUfaCo5gW2bXdM+YoCchVA5ec=;
        b=Y2lljDULxBw9j/8MwIqmb9fqUAuj+7/vH/5YMkngkdQbnKrqOxpmuqEq7Fl55WHXY2
         HAQUmxZr44ncGeqQpoILIhnPpcPweIH/35o2q6NvAdeeCublcoiRtmvnCWfcDWaTFBqb
         6buJS+Z3k67GOQduKFDibWXWgf0W653ugYrFPQPwM/MPtvhz+o0jVHya4v0Ovf8Svi6d
         73oEMBE2YecxLknR45krJ/O+Lxro1RB3MWNeZ2Jio6UCizhv32D1TnNy5NOBe8Xnnbiw
         1CkOPm6C70luu8+gyHxUWNg/lFbA0WxYAcorGVouPdThNY7uMVrUNWeSoL5Yvdg+zBls
         IOcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=M0gahmUK;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l125sor187588iof.41.2019.01.14.05.24.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 05:24:15 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=M0gahmUK;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BszPOXukd/CRgTGG7KPUfaCo5gW2bXdM+YoCchVA5ec=;
        b=M0gahmUK46IwVZQFlJr02IUlbdXcgG1a4pJGRzQQMjkDsPRRluRSpxmipOFZ5HBEeG
         d9zejSLeM8P2SdMoTI6WtluYNmgHoBUdyrLj/kNHmU85x9776vlb3h03rrXyBpdLIsNj
         lgq5cPngAjK4gzOpO032GWHUws841Rk3hVRIf+s9igEbrRumdVnmfd+0hlmgwxEKDIht
         bHa6mq/BNoN6H9tFee0qZGxblEvtQPjVE9jt+C0AULgASGskiihiavAEmwH5mEeJoR5v
         oiyTSP/TvXfIshXjUIiNZHGxCfRfi4yzvqSylZbJaU3MKr0IyE8XcvzJcvWNFOkX8DMz
         DvsA==
X-Google-Smtp-Source: ALg8bN7UJ4bYVPQqImOJGWIZZmUioMOn4hBC6sxvYKeuVEGzryuRUWNTY0nkT7C6Ew5hCHvtCD0eY/cmQbvAFVu6pmA=
X-Received: by 2002:a6b:fa01:: with SMTP id p1mr9893214ioh.271.1547472254932;
 Mon, 14 Jan 2019 05:24:14 -0800 (PST)
MIME-Version: 1.0
References: <20190111185842.13978-1-aryabinin@virtuozzo.com>
In-Reply-To: <20190111185842.13978-1-aryabinin@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 14 Jan 2019 14:24:03 +0100
Message-ID:
 <CACT4Y+YV+jjcXE1oa=Gf031KAgEy40Nq83x3_nj3TwQpw3b+Ug@mail.gmail.com>
Subject: Re: [PATCH] kasan: Remove use after scope bugs detection.
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Qian Cai <cai@lca.pw>, 
	Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114132403.ws7yGGvttwOSBsR0Dw6RqKbUDr9z9e2scLmEsmYGBS4@z>

On Fri, Jan 11, 2019 at 7:58 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
> Use after scope bugs detector seems to be almost entirely useless
> for the linux kernel. It exists over two years, but I've seen only
> one valid bug so far [1]. And the bug was fixed before it has been
> reported. There were some other use-after-scope reports, but they
> were false-positives due to different reasons like incompatibility
> with structleak plugin.
>
> This feature significantly increases stack usage, especially with
> GCC < 9 version, and causes a 32K stack overflow. It probably
> adds performance penalty too.
>
> Given all that, let's remove use-after-scope detector entirely.
>
> While preparing this patch I've noticed that we mistakenly enable
> use-after-scope detection for clang compiler regardless of
> CONFIG_KASAN_EXTRA setting. This is also fixed now.

Hi Andrey,

I am on a fence. On one hand removing bug detection sucks and each
case of a missed memory corruption leads to a splash of assorted bug
reports by syzbot. On the other hand everything you said is true.
Maybe support for CONFIG_VMAP_STACK will enable stacks larger then
PAGE_ALLOC_COSTLY_ORDER?




> [1] http://lkml.kernel.org/r/<20171129052106.rhgbjhhis53hkgfn@wfg-t540p.sh.intel.com>
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> ---
>  arch/arm64/include/asm/memory.h |  4 ----
>  lib/Kconfig.debug               |  1 -
>  lib/Kconfig.kasan               | 10 ----------
>  lib/test_kasan.c                | 24 ------------------------
>  mm/kasan/generic.c              | 19 -------------------
>  mm/kasan/generic_report.c       |  3 ---
>  mm/kasan/kasan.h                |  3 ---
>  scripts/Makefile.kasan          |  5 -----
>  scripts/gcc-plugins/Kconfig     |  4 ----
>  9 files changed, 73 deletions(-)
>
> diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
> index e1ec947e7c0c..0e236a99b3ef 100644
> --- a/arch/arm64/include/asm/memory.h
> +++ b/arch/arm64/include/asm/memory.h
> @@ -80,11 +80,7 @@
>   */
>  #ifdef CONFIG_KASAN
>  #define KASAN_SHADOW_SIZE      (UL(1) << (VA_BITS - KASAN_SHADOW_SCALE_SHIFT))
> -#ifdef CONFIG_KASAN_EXTRA
> -#define KASAN_THREAD_SHIFT     2
> -#else
>  #define KASAN_THREAD_SHIFT     1
> -#endif /* CONFIG_KASAN_EXTRA */
>  #else
>  #define KASAN_SHADOW_SIZE      (0)
>  #define KASAN_THREAD_SHIFT     0
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index d4df5b24d75e..a219f3488ad7 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -222,7 +222,6 @@ config ENABLE_MUST_CHECK
>  config FRAME_WARN
>         int "Warn for stack frames larger than (needs gcc 4.4)"
>         range 0 8192
> -       default 3072 if KASAN_EXTRA
>         default 2048 if GCC_PLUGIN_LATENT_ENTROPY
>         default 1280 if (!64BIT && PARISC)
>         default 1024 if (!64BIT && !PARISC)
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index d8c474b6691e..67d7d1309c52 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -78,16 +78,6 @@ config KASAN_SW_TAGS
>
>  endchoice
>
> -config KASAN_EXTRA
> -       bool "KASAN: extra checks"
> -       depends on KASAN_GENERIC && DEBUG_KERNEL && !COMPILE_TEST
> -       help
> -         This enables further checks in generic KASAN, for now it only
> -         includes the address-use-after-scope check that can lead to
> -         excessive kernel stack usage, frame size warnings and longer
> -         compile time.
> -         See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715
> -
>  choice
>         prompt "Instrumentation type"
>         depends on KASAN
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index 51b78405bf24..7de2702621dc 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -480,29 +480,6 @@ static noinline void __init copy_user_test(void)
>         kfree(kmem);
>  }
>
> -static noinline void __init use_after_scope_test(void)
> -{
> -       volatile char *volatile p;
> -
> -       pr_info("use-after-scope on int\n");
> -       {
> -               int local = 0;
> -
> -               p = (char *)&local;
> -       }
> -       p[0] = 1;
> -       p[3] = 1;
> -
> -       pr_info("use-after-scope on array\n");
> -       {
> -               char local[1024] = {0};
> -
> -               p = local;
> -       }
> -       p[0] = 1;
> -       p[1023] = 1;
> -}
> -
>  static noinline void __init kasan_alloca_oob_left(void)
>  {
>         volatile int i = 10;
> @@ -682,7 +659,6 @@ static int __init kmalloc_tests_init(void)
>         kasan_alloca_oob_right();
>         ksize_unpoisons_memory();
>         copy_user_test();
> -       use_after_scope_test();
>         kmem_cache_double_free();
>         kmem_cache_invalid_free();
>         kasan_memchr();
> diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
> index ccb6207276e3..504c79363a34 100644
> --- a/mm/kasan/generic.c
> +++ b/mm/kasan/generic.c
> @@ -275,25 +275,6 @@ EXPORT_SYMBOL(__asan_storeN_noabort);
>  void __asan_handle_no_return(void) {}
>  EXPORT_SYMBOL(__asan_handle_no_return);
>
> -/* Emitted by compiler to poison large objects when they go out of scope. */
> -void __asan_poison_stack_memory(const void *addr, size_t size)
> -{
> -       /*
> -        * Addr is KASAN_SHADOW_SCALE_SIZE-aligned and the object is surrounded
> -        * by redzones, so we simply round up size to simplify logic.
> -        */
> -       kasan_poison_shadow(addr, round_up(size, KASAN_SHADOW_SCALE_SIZE),
> -                           KASAN_USE_AFTER_SCOPE);
> -}
> -EXPORT_SYMBOL(__asan_poison_stack_memory);
> -
> -/* Emitted by compiler to unpoison large objects when they go into scope. */
> -void __asan_unpoison_stack_memory(const void *addr, size_t size)
> -{
> -       kasan_unpoison_shadow(addr, size);
> -}
> -EXPORT_SYMBOL(__asan_unpoison_stack_memory);
> -
>  /* Emitted by compiler to poison alloca()ed objects. */
>  void __asan_alloca_poison(unsigned long addr, size_t size)
>  {
> diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
> index 5e12035888f2..36c645939bc9 100644
> --- a/mm/kasan/generic_report.c
> +++ b/mm/kasan/generic_report.c
> @@ -82,9 +82,6 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
>         case KASAN_KMALLOC_FREE:
>                 bug_type = "use-after-free";
>                 break;
> -       case KASAN_USE_AFTER_SCOPE:
> -               bug_type = "use-after-scope";
> -               break;
>         case KASAN_ALLOCA_LEFT:
>         case KASAN_ALLOCA_RIGHT:
>                 bug_type = "alloca-out-of-bounds";
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index ea51b2d898ec..3e0c11f7d7a1 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -34,7 +34,6 @@
>  #define KASAN_STACK_MID         0xF2
>  #define KASAN_STACK_RIGHT       0xF3
>  #define KASAN_STACK_PARTIAL     0xF4
> -#define KASAN_USE_AFTER_SCOPE   0xF8
>
>  /*
>   * alloca redzone shadow values
> @@ -187,8 +186,6 @@ void __asan_unregister_globals(struct kasan_global *globals, size_t size);
>  void __asan_loadN(unsigned long addr, size_t size);
>  void __asan_storeN(unsigned long addr, size_t size);
>  void __asan_handle_no_return(void);
> -void __asan_poison_stack_memory(const void *addr, size_t size);
> -void __asan_unpoison_stack_memory(const void *addr, size_t size);
>  void __asan_alloca_poison(unsigned long addr, size_t size);
>  void __asan_allocas_unpoison(const void *stack_top, const void *stack_bottom);
>
> diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
> index 25c259df8ffa..f1fb8e502657 100644
> --- a/scripts/Makefile.kasan
> +++ b/scripts/Makefile.kasan
> @@ -27,14 +27,9 @@ else
>          $(call cc-param,asan-globals=1) \
>          $(call cc-param,asan-instrumentation-with-call-threshold=$(call_threshold)) \
>          $(call cc-param,asan-stack=1) \
> -        $(call cc-param,asan-use-after-scope=1) \
>          $(call cc-param,asan-instrument-allocas=1)
>  endif
>
> -ifdef CONFIG_KASAN_EXTRA
> -CFLAGS_KASAN += $(call cc-option, -fsanitize-address-use-after-scope)
> -endif
> -
>  endif # CONFIG_KASAN_GENERIC
>
>  ifdef CONFIG_KASAN_SW_TAGS
> diff --git a/scripts/gcc-plugins/Kconfig b/scripts/gcc-plugins/Kconfig
> index d45f7f36b859..d9fd9988ef27 100644
> --- a/scripts/gcc-plugins/Kconfig
> +++ b/scripts/gcc-plugins/Kconfig
> @@ -68,10 +68,6 @@ config GCC_PLUGIN_LATENT_ENTROPY
>
>  config GCC_PLUGIN_STRUCTLEAK
>         bool "Force initialization of variables containing userspace addresses"
> -       # Currently STRUCTLEAK inserts initialization out of live scope of
> -       # variables from KASAN point of view. This leads to KASAN false
> -       # positive reports. Prohibit this combination for now.
> -       depends on !KASAN_EXTRA
>         help
>           This plugin zero-initializes any structures containing a
>           __user attribute. This can prevent some classes of information
> --
> 2.19.2
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190111185842.13978-1-aryabinin%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.

