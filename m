Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 669B16B0253
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 12:50:53 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id 184so79242390pff.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 09:50:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m67si1658542pfi.45.2016.04.08.09.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 09:50:52 -0700 (PDT)
Date: Fri, 8 Apr 2016 09:50:51 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] lib: lz4: fixed zram with lz4 on big endian machines
Message-ID: <20160408165051.GB16346@kroah.com>
References: <1460129004-2011-1-git-send-email-rsalvaterra@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460129004-2011-1-git-send-email-rsalvaterra@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sergey.senozhatsky@gmail.com, sergey.senozhatsky.work@gmail.com, eunb.song@samsung.com, minchan@kernel.org, chanho.min@lge.com, kyungsik.lee@lge.com, stable@vger.kernel.org

On Fri, Apr 08, 2016 at 04:23:24PM +0100, Rui Salvaterra wrote:
> Based on Sergey's test patch [1], this fixes zram with lz4 compression on big endian cpus. Tested on ppc64 with no regression on x86_64.

Please wrap your text at 72 columns in a changelog comment.

> 
> [1] http://marc.info/?l=linux-kernel&m=145994470805853&w=4
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Rui Salvaterra <rsalvaterra@gmail.com>

Please attribute Sergey here in the signed-off-by area with a
"Suggested-by:" type mark

> ---
>  lib/lz4/lz4defs.h | 29 +++++++++++++++--------------
>  1 file changed, 15 insertions(+), 14 deletions(-)
> 
> diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
> index abcecdc..a98c08c 100644
> --- a/lib/lz4/lz4defs.h
> +++ b/lib/lz4/lz4defs.h
> @@ -11,8 +11,7 @@
>  /*
>   * Detects 64 bits mode
>   */
> -#if (defined(__x86_64__) || defined(__x86_64) || defined(__amd64__) \
> -	|| defined(__ppc64__) || defined(__LP64__))
> +#if defined(CONFIG_64BIT)

This patch seems to do two different things, clean up the #if tests, and
change the endian of some calls.  Can you break this up into 2 different
patches?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
