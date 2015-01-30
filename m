Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEAC6B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 11:02:54 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id z12so27749966wgg.3
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:02:54 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id h2si21431931wjz.86.2015.01.30.08.02.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 08:02:45 -0800 (PST)
Date: Fri, 30 Jan 2015 16:02:13 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 03/19] arm: expose number of page table levels on Kconfig
 level
Message-ID: <20150130160212.GP26493@n2100.arm.linux.org.uk>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1422629008-13689-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422629008-13689-4-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>

It'd be nice to see the cover for this series so that people know the
reason behind this change is.  Maybe it'd be a good idea to add a
pointer or some description below the "---" to such patches which
are otherwise totally meaningless to the people you add to the Cc
line?

On Fri, Jan 30, 2015 at 04:43:12PM +0200, Kirill A. Shutemov wrote:
> We would want to use number of page table level to define mm_struct.
> Let's expose it as CONFIG_PGTABLE_LEVELS.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> ---
>  arch/arm/Kconfig | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 4211507e2bca..d7dca652573f 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -286,6 +286,11 @@ config GENERIC_BUG
>  	def_bool y
>  	depends on BUG
>  
> +config PGTABLE_LEVELS
> +	int
> +	default 3 if ARM_LPAE
> +	default 2
> +
>  source "init/Kconfig"
>  
>  source "kernel/Kconfig.freezer"
> -- 
> 2.1.4
> 

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
