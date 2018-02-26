Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57F6E6B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 18:57:36 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id i129so16145914ioi.1
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 15:57:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o128sor1050526ioo.295.2018.02.26.15.57.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 15:57:35 -0800 (PST)
Date: Mon, 26 Feb 2018 15:57:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Provide consistent declaration for
 num_poisoned_pages
In-Reply-To: <1519686565-8224-1-git-send-email-linux@roeck-us.net>
Message-ID: <alpine.DEB.2.20.1802261556420.236524@chino.kir.corp.google.com>
References: <1519686565-8224-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>

On Mon, 26 Feb 2018, Guenter Roeck wrote:

> clang reports the following compile warning.
> 
> In file included from mm/vmscan.c:56:
> ./include/linux/swapops.h:327:22: warning:
> 	section attribute is specified on redeclared variable [-Wsection]
> extern atomic_long_t num_poisoned_pages __read_mostly;
>                      ^
> ./include/linux/mm.h:2585:22: note: previous declaration is here
> extern atomic_long_t num_poisoned_pages;
>                      ^
> 
> Let's use __read_mostly everywhere.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> Cc: Matthias Kaehlcke <mka@chromium.org>
> ---
>  include/linux/mm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42adb1a..bd4bd59f02c1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2582,7 +2582,7 @@ extern int get_hwpoison_page(struct page *page);
>  extern int sysctl_memory_failure_early_kill;
>  extern int sysctl_memory_failure_recovery;
>  extern void shake_page(struct page *p, int access);
> -extern atomic_long_t num_poisoned_pages;
> +extern atomic_long_t num_poisoned_pages __read_mostly;
>  extern int soft_offline_page(struct page *page, int flags);
>  
>  

No objection to the patch, of course, but I'm wondering if it's (1) the 
only such clang compile warning for mm/, and (2) if the re-declaration in 
mm.h could be avoided by including swapops.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
