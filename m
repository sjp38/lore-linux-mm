Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id D08C16B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:28:55 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id f20so7340266otd.9
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:28:55 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id l22si351698otd.122.2017.06.22.02.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 02:28:55 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id c189so5674914oia.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:28:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170622090049.10658-1-colin.king@canonical.com>
References: <20170622090049.10658-1-colin.king@canonical.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 22 Jun 2017 11:28:34 +0200
Message-ID: <CACT4Y+Yqadr1obZCqpQVTp4DrjOLrshnyPp6L8owoqUybttvSQ@mail.gmail.com>
Subject: Re: [PATCH] kasan: make function get_wild_bug_type static
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin King <colin.king@canonical.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel-janitors@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jun 22, 2017 at 11:00 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> The helper function get_wild_bug_type does not need to be in global scope,
> so make it static.
>
> Cleans up sparse warning:
> "symbol 'get_wild_bug_type' was not declared. Should it be static?"
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Dmitry Vyukov <dvyukov@google.com>

> ---
>  mm/kasan/report.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index beee0e980e2d..04bb1d3eb9ec 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -107,7 +107,7 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
>         return bug_type;
>  }
>
> -const char *get_wild_bug_type(struct kasan_access_info *info)
> +static const char *get_wild_bug_type(struct kasan_access_info *info)
>  {
>         const char *bug_type = "unknown-crash";
>
> --
> 2.11.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
