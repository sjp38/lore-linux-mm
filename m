Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id D5F096B00AC
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 04:27:55 -0400 (EDT)
Subject: Re: [PATCH] idr: Rename MAX_LEVEL to MAX_ID_LEVEL
From: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Date: Tue, 11 Sep 2012 10:27:47 +0200
In-Reply-To: <20120910131426.GA12431@localhost>
References: <20120910131426.GA12431@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1347352069.14488.12.camel@thorin>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

Hi!

On Mon, 2012-09-10 at 21:14 +0800, Fengguang Wu wrote:
> To avoid name conflicts:
> 
> drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
> 
> Andrew: the conflict happens in Glauber's kmemcg-slab tree.  So it's
> better to quickly push this pre-fix to upstream before Glauber's patches.
> 
> 
>  include/linux/idr.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- linux.orig/include/linux/idr.h	2012-09-10 21:08:51.177452944 +0800
> +++ linux/include/linux/idr.h	2012-09-10 21:08:57.729452732 +0800
> @@ -43,10 +43,10 @@
>  #define MAX_ID_MASK (MAX_ID_BIT - 1)
>  
>  /* Leave the possibility of an incomplete final layer */
> -#define MAX_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS
> +#define MAX_ID_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS

And while you are it: Please add '(' and ')' around it as in 

#define MAX_ID_LEVEL ((MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS)


>  /* Number of id_layer structs to leave in free list */
> -#define IDR_FREE_MAX MAX_LEVEL + MAX_LEVEL
> +#define IDR_FREE_MAX MAX_ID_LEVEL + MAX_ID_LEVEL
#define IDR_FREE_MAX (MAX_ID_LEVEL + MAX_ID_LEVEL)

For starters (sleeping in "cpp-101";-): People may use it as in
"IDR_FREE_MAX * 2".
And I didn't look into that file - that should be changed everywhere in
that way.

	Bernd
-- 
Bernd Petrovitsch                  Email : bernd@petrovitsch.priv.at
                     LUGA : http://www.luga.at

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
