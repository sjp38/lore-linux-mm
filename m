Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE4806B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 15:24:01 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so20051196pfa.3
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 12:24:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l12si11026646plc.247.2017.02.09.12.24.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 12:24:00 -0800 (PST)
Date: Thu, 9 Feb 2017 21:13:29 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3 v2 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170209201329.GA12148@kroah.com>
References: <df828d70-3962-2e43-0512-1777a9842bb2@sonymobile.com>
 <e3dc46d0-7431-c97c-d8cf-824f30706175@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e3dc46d0-7431-c97c-d8cf-824f30706175@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu, Feb 09, 2017 at 04:42:35PM +0100, peter enderborg wrote:
> This collects stats for shrinker calls and how much
> waste work we do within the lowmemorykiller.
> 
> Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
> ---
>  drivers/staging/android/Kconfig                 | 11 ++++
>  drivers/staging/android/Makefile                |  1 +
>  drivers/staging/android/lowmemorykiller.c       |  9 ++-
>  drivers/staging/android/lowmemorykiller_stats.c | 85 +++++++++++++++++++++++++
>  drivers/staging/android/lowmemorykiller_stats.h | 29 +++++++++
>  5 files changed, 134 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/staging/android/lowmemorykiller_stats.c
>  create mode 100644 drivers/staging/android/lowmemorykiller_stats.h

What changed from v1?

> @@ -72,6 +73,7 @@ static unsigned long lowmem_deathpending_timeout;
>  static unsigned long lowmem_count(struct shrinker *s,
>                    struct shrink_control *sc)
>  {
> +    lmk_inc_stats(LMK_COUNT);
>      return global_node_page_state(NR_ACTIVE_ANON) +
>          global_node_page_state(NR_ACTIVE_FILE) +
>          global_node_page_state(NR_INACTIVE_ANON) +

Your email client is eating tabs and spitting out spaces, making this
impossible to even consider being merged :(

Please fix your email client, documentation for how to do so is in the
kernel Documentation directory.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
