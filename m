Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8E77E6B0256
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:45:31 -0400 (EDT)
Date: Mon, 10 May 2010 19:44:47 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 12/25] lmb: Move lmb arrays to static storage in lmb.c and make their size a variable
Message-ID: <20100510104446.GC14278@linux-sh.org>
References: <1273484339-28911-4-git-send-email-benh@kernel.crashing.org> <1273484339-28911-5-git-send-email-benh@kernel.crashing.org> <1273484339-28911-6-git-send-email-benh@kernel.crashing.org> <1273484339-28911-7-git-send-email-benh@kernel.crashing.org> <1273484339-28911-8-git-send-email-benh@kernel.crashing.org> <1273484339-28911-9-git-send-email-benh@kernel.crashing.org> <1273484339-28911-10-git-send-email-benh@kernel.crashing.org> <1273484339-28911-11-git-send-email-benh@kernel.crashing.org> <1273484339-28911-12-git-send-email-benh@kernel.crashing.org> <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Mon, May 10, 2010 at 07:38:46PM +1000, Benjamin Herrenschmidt wrote:
> diff --git a/include/linux/lmb.h b/include/linux/lmb.h
> index 27c2386..e575801 100644
> --- a/include/linux/lmb.h
> +++ b/include/linux/lmb.h
> @@ -18,7 +18,7 @@
>  
>  #include <asm/lmb.h>
>  
> -#define MAX_LMB_REGIONS 128
> +#define INIT_LMB_REGIONS 128
>  
>  struct lmb_region {
>  	phys_addr_t base;

Perhaps it would be better to weight this against MAX_ACTIVE_REGIONS for
the ARCH_POPULATES_NODE_MAP case? The early node map is already using
that size, at least.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
