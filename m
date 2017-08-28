Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB9D46B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 09:29:53 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id y98so2081995ita.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 06:29:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b125sor183245iti.17.2017.08.28.06.29.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Aug 2017 06:29:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2e26a2cef6e2148a7aadb77e9e64835fab6b4dc2.1503769223.git.arvind.yadav.cs@gmail.com>
References: <2e26a2cef6e2148a7aadb77e9e64835fab6b4dc2.1503769223.git.arvind.yadav.cs@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 28 Aug 2017 09:29:11 -0400
Message-ID: <CALZtONCY64ck=FDriOR=m_RJnURto2rGP76mu-k5-g=c-My_yw@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: constify struct kernel_param_ops uses
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Seth Jennings <sjenning@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sat, Aug 26, 2017 at 1:41 PM, Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:
> kernel_param_ops are not supposed to change at runtime. All functions
> working with kernel_param_ops provided by <linux/moduleparam.h> work
> with const kernel_param_ops. So mark the non-const structs as const.
>
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Reviewed-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zswap.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index d39581a..030fbf9 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -82,7 +82,7 @@ static u64 zswap_duplicate_entry;
>  static bool zswap_enabled;
>  static int zswap_enabled_param_set(const char *,
>                                    const struct kernel_param *);
> -static struct kernel_param_ops zswap_enabled_param_ops = {
> +static const struct kernel_param_ops zswap_enabled_param_ops = {
>         .set =          zswap_enabled_param_set,
>         .get =          param_get_bool,
>  };
> @@ -93,7 +93,7 @@ module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644);
>  static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
>  static int zswap_compressor_param_set(const char *,
>                                       const struct kernel_param *);
> -static struct kernel_param_ops zswap_compressor_param_ops = {
> +static const struct kernel_param_ops zswap_compressor_param_ops = {
>         .set =          zswap_compressor_param_set,
>         .get =          param_get_charp,
>         .free =         param_free_charp,
> @@ -105,7 +105,7 @@ module_param_cb(compressor, &zswap_compressor_param_ops,
>  #define ZSWAP_ZPOOL_DEFAULT "zbud"
>  static char *zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
>  static int zswap_zpool_param_set(const char *, const struct kernel_param *);
> -static struct kernel_param_ops zswap_zpool_param_ops = {
> +static const struct kernel_param_ops zswap_zpool_param_ops = {
>         .set =          zswap_zpool_param_set,
>         .get =          param_get_charp,
>         .free =         param_free_charp,
> --
> 2.7.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
