Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id AE4B96B0062
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 20:28:31 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so779241pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 17:28:31 -0800 (PST)
Date: Wed, 14 Nov 2012 17:28:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] asm-generic: add __WARN() to bug.h
In-Reply-To: <50A43E5E.9040905@xenotime.net>
Message-ID: <alpine.DEB.2.00.1211141726380.4749@chino.kir.corp.google.com>
References: <20121114163042.64f0c0495663331b9c2d60d6@canb.auug.org.au> <50A43E5E.9040905@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org

On Wed, 14 Nov 2012, Randy Dunlap wrote:

> --- linux-next-20121114.orig/include/asm-generic/bug.h
> +++ linux-next-20121114/include/asm-generic/bug.h
> @@ -129,6 +129,10 @@ extern void warn_slowpath_null(const cha
>  })
>  #endif
>  
> +#ifndef __WARN
> +#define __WARN()	do {} while (0)
> +#endif
> +
>  #define WARN_TAINT(condition, taint, format...) WARN_ON(condition)
>  
>  #endif

__WARN() isn't supposed to be used by generic code, though.  The 
mm/balloon_compaction.c error should be resolved by 
mm-introduce-a-common-interface-for-balloon-pages-mobility-fix-fix-fix.patch 
added to -mm today.  It converts the __WARN() there into WARN_ON(1) which 
is defined appropriately for CONFIG_BUG=n.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
