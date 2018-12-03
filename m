Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 409B86B6B2E
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 16:34:23 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 89so11027891ple.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 13:34:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor20567223pfj.35.2018.12.03.13.34.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 13:34:19 -0800 (PST)
Date: Mon, 3 Dec 2018 13:34:16 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] psi: fix reference to kernel commandline enable
Message-ID: <20181203213416.GA12627@cmpxchg.org>
References: <99058450a8c792cde07c7ced343bf1711c75b8f3.1543742330.git.baruch@tkos.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <99058450a8c792cde07c7ced343bf1711c75b8f3.1543742330.git.baruch@tkos.co.il>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baruch Siach <baruch@tkos.co.il>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Sun, Dec 02, 2018 at 11:18:50AM +0200, Baruch Siach wrote:
> The kernel commandline parameter named in CONFIG_PSI_DEFAULT_DISABLED
> help text contradicts the documentation in kernel-parameters.txt, and
> the code. Fix that.
> 
> Fixes: e0c274472d ("psi: make disabling/enabling easier for vendor kernels")
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Doh, thanks Baruch.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> ---
>  init/Kconfig | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index cf5b5a0dcbc2..ed9352513c32 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -515,8 +515,8 @@ config PSI_DEFAULT_DISABLED
>  	depends on PSI
>  	help
>  	  If set, pressure stall information tracking will be disabled
> -	  per default but can be enabled through passing psi_enable=1
> -	  on the kernel commandline during boot.
> +	  per default but can be enabled through passing psi=1 on the
> +	  kernel commandline during boot.
>  
>  endmenu # "CPU/Task time and stats accounting"
