Date: Wed, 10 Aug 2005 08:48:37 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
In-Reply-To: <200508100923.55749.phillips@arcor.de>
Message-ID: <Pine.LNX.4.61.0508100843420.18223@goblin.wat.veritas.com>
References: <42F57FCA.9040805@yahoo.com.au> <200508090724.30962.phillips@arcor.de>
 <20050808145430.15394c3c.akpm@osdl.org> <200508100923.55749.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Aug 2005, Daniel Phillips wrote:
> --- 2.6.13-rc5-mm1.clean/include/linux/page-flags.h	2005-08-09 18:23:31.000000000 -0400
> +++ 2.6.13-rc5-mm1/include/linux/page-flags.h	2005-08-09 18:59:57.000000000 -0400
> @@ -61,7 +61,7 @@
>  #define PG_active		 6
>  #define PG_slab			 7	/* slab debug (Suparna wants this) */
>  
> -#define PG_checked		 8	/* kill me in 2.5.<early>. */
> +#define PG_miscfs		 8	/* kill me in 2.5.<early>. */
>  #define PG_fs_misc		 8

And all those PageMiscFS macros you're adding to the PageFsMisc ones:
doesn't look like progress to me ;)

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
