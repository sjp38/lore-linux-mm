Date: Wed, 13 Jun 2007 19:47:27 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [KJ PATCH] Replacing memcpy(dest,src,PAGE_SIZE) with copy_page(dest,src) in arch/i386/mm/init.c
Message-ID: <20070613194726.GB8273@ucw.cz>
References: <1181618174.2282.16.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181618174.2282.16.camel@shani-win>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shani Moideen <shani.moideen@wipro.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@lists.osdl.org
List-ID: <linux-mm.kvack.org>

On Tue 2007-06-12 08:46:14, Shani Moideen wrote:
> Hi,
> Replacing memcpy(dest,src,PAGE_SIZE) with copy_page(dest,src) in arch/i386/mm/init.c.
> 
> Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
> ----
> 
> 
> diff --git a/arch/i386/mm/init.c b/arch/i386/mm/init.c
> index ae43688..7dc3d46 100644
> --- a/arch/i386/mm/init.c
> +++ b/arch/i386/mm/init.c
> @@ -397,7 +397,7 @@ char __nosavedata swsusp_pg_dir[PAGE_SIZE]
>  
>  static inline void save_pg_dir(void)
>  {
> -	memcpy(swsusp_pg_dir, swapper_pg_dir, PAGE_SIZE);
> +	copy_page(swsusp_pg_dir, swapper_pg_dir);
>  }
>  #else
>  static inline void save_pg_dir(void)


ACK.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
