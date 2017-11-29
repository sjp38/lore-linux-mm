Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF006B0253
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 19:40:18 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id p28so1550795uaf.6
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 16:40:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor179953ual.66.2017.11.28.16.40.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 16:40:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1510959741-31109-2-git-send-email-yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com> <1510959741-31109-2-git-send-email-yang.s@alibaba-inc.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 28 Nov 2017 16:40:15 -0800
Message-ID: <CAGXu5jK-kzUF_2aoVazrkBX3oR+jAnMc4BoH4Dyznuj4H8dz_Q@mail.gmail.com>
Subject: Re: [PATCH 2/8] fs: pstore: remove unused hardirq.h
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-crypto <linux-crypto@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>

On Fri, Nov 17, 2017 at 3:02 PM, Yang Shi <yang.s@alibaba-inc.com> wrote:
> Preempt counter APIs have been split out, currently, hardirq.h just
> includes irq_enter/exit APIs which are not used by pstore at all.
>
> So, remove the unused hardirq.h.
>
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Anton Vorontsov <anton@enomsg.org>
> Cc: Colin Cross <ccross@android.com>
> Cc: Tony Luck <tony.luck@intel.com>

Thanks! I've applied this for -next.

-Kees

> ---
>  fs/pstore/platform.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/fs/pstore/platform.c b/fs/pstore/platform.c
> index 2b21d18..25dcef4 100644
> --- a/fs/pstore/platform.c
> +++ b/fs/pstore/platform.c
> @@ -41,7 +41,6 @@
>  #include <linux/timer.h>
>  #include <linux/slab.h>
>  #include <linux/uaccess.h>
> -#include <linux/hardirq.h>
>  #include <linux/jiffies.h>
>  #include <linux/workqueue.h>
>
> --
> 1.8.3.1
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
