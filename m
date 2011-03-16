Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 44FD08D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 22:54:19 -0400 (EDT)
Subject: Re: [PATCH 1/8] drivers/random: Cache align ip_random better
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20110316022804.27679.qmail@science.horizon.com>
References: <20110316022804.27679.qmail@science.horizon.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Mar 2011 21:54:14 -0500
Message-ID: <1300244054.3128.417.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 2011-03-13 at 20:20 -0400, George Spelvin wrote:
> Cache aligning the secret[] buffer makes copying from it infinitesimally
> more efficient.

Acked-by: Matt Mackall <mpm@selenic.com>

> ---
>  drivers/char/random.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index 72a4fcb..4bcc4f2 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -1417,8 +1417,8 @@ static __u32 twothirdsMD4Transform(__u32 const buf[4], __u32 const in[12])
>  #define HASH_MASK ((1 << HASH_BITS) - 1)
>  
>  static struct keydata {
> -	__u32 count; /* already shifted to the final position */
>  	__u32 secret[12];
> +	__u32 count; /* already shifted to the final position */
>  } ____cacheline_aligned ip_keydata[2];
>  
>  static unsigned int ip_cnt;


-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
