Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 186A96B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 18:36:39 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 67so79295674ioh.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 15:36:39 -0800 (PST)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id f190si2493522itf.86.2017.02.10.15.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 15:36:38 -0800 (PST)
Received: by mail-io0-x234.google.com with SMTP id j18so61984947ioe.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 15:36:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170209131625.GA16954@pjb1027-Latitude-E5410>
References: <20170209131625.GA16954@pjb1027-Latitude-E5410>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 10 Feb 2017 15:36:37 -0800
Message-ID: <CAGXu5jKofDhycUbLGMLNPM3LwjKuW1kGAbthSS1qufEB6bwOPA@mail.gmail.com>
Subject: Re: [PATCH] mm: testcases for RODATA: fix config dependency
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jinbum Park <jinb.park7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Valentin Rothberg <valentinrothberg@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>

On Thu, Feb 9, 2017 at 5:16 AM, Jinbum Park <jinb.park7@gmail.com> wrote:
> Since DEBUG_RODATA has renamed to STRICT_KERNEL_RWX,
> Fix the config dependency.
>
> Reported-by: Valentin Rothberg <valentinrothberg@gmail.com>
> Signed-off-by: Jinbum Park <jinb.park7@gmail.com>
> ---
>  mm/Kconfig.debug | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
> index 3e5eada..3c88b7e 100644
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug
> @@ -93,7 +93,7 @@ config DEBUG_PAGE_REF
>
>  config DEBUG_RODATA_TEST
>      bool "Testcase for the marking rodata read-only"
> -    depends on DEBUG_RODATA
> +    depends on STRICT_KERNEL_RWX
>      ---help---
>        This option enables a testcase for the setting rodata read-only.

Great, thanks!

Acked-by: Kees Cook <keescook@chromium.org>

Andrew, do you want to take this patch, since it applies on top of
"mm: add arch-independent testcases for RODATA", or do you want me to
take both patches into my KSPP tree which has the DEBUG_RODATA ->
STRICT_KERNEL_RWX renaming series?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
