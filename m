Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B156A6B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:34:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a6so4453796pff.17
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 00:34:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc11sor1344042plb.71.2017.11.30.00.34.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 00:34:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171129215050.158653-6-paullawrence@google.com>
References: <20171129215050.158653-1-paullawrence@google.com> <20171129215050.158653-6-paullawrence@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 30 Nov 2017 09:34:18 +0100
Message-ID: <CACT4Y+YEmjU=9TvKP0FEJ=GJyO2G_hx09M1TYW_4B7c+HyYMhg@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] kasan: add compiler support for clang
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

On Wed, Nov 29, 2017 at 10:50 PM, 'Paul Lawrence' via kasan-dev
<kasan-dev@googlegroups.com> wrote:
> For now we can hard-code ASAN ABI level 5, since historical clang builds
> can't build the kernel anyway.  We also need to emulate gcc's
> __SANITIZE_ADDRESS__ flag, or memset() calls won't be instrumented.
>
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
>
> ---
>  include/linux/compiler-clang.h | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
> index 3b609edffa8f..d02a4df3f473 100644
> --- a/include/linux/compiler-clang.h
> +++ b/include/linux/compiler-clang.h
> @@ -19,3 +19,11 @@
>
>  #define randomized_struct_fields_start struct {
>  #define randomized_struct_fields_end   };
> +
> +/* all clang versions usable with the kernel support KASAN ABI version 5 */
> +#define KASAN_ABI_VERSION 5
> +
> +/* emulate gcc's __SANITIZE_ADDRESS__ flag */
> +#if __has_feature(address_sanitizer)
> +#define __SANITIZE_ADDRESS__
> +#endif

Reviewed-by: Dmitry Vyukov <dvyukov@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
