Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0656B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 09:56:00 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n195so10056454itg.14
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 06:56:00 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h6si682222otg.511.2017.10.06.06.55.59
        for <linux-mm@kvack.org>;
        Fri, 06 Oct 2017 06:55:59 -0700 (PDT)
Date: Fri, 6 Oct 2017 14:55:55 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: change /sys/kernel/debug/kmemleak permissions
 from 0444 to 0644
Message-ID: <20171006135554.eiwezlqq6gyhy6wa@armageddon.cambridge.arm.com>
References: <150728996582.744328.11541332857988399411.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150728996582.744328.11541332857988399411.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, Oct 06, 2017 at 02:39:25PM +0300, Konstantin Khlebnikov wrote:
> Kmemleak could be tweaked in runtime by writing commands into debugfs file.
> Root anyway can use it, but without write-bit this interface isn't obvious.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  mm/kmemleak.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 7780cd83a495..fca3452e56c1 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -2104,7 +2104,7 @@ static int __init kmemleak_late_init(void)
>  		return -ENOMEM;
>  	}
>  
> -	dentry = debugfs_create_file("kmemleak", S_IRUGO, NULL, NULL,
> +	dentry = debugfs_create_file("kmemleak", 0644, NULL, NULL,
>  				     &kmemleak_fops);
>  	if (!dentry)
>  		pr_warn("Failed to create the debugfs kmemleak file\n");

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
