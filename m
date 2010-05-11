Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0AC6B0227
	for <linux-mm@kvack.org>; Tue, 11 May 2010 08:31:47 -0400 (EDT)
Date: Tue, 11 May 2010 14:30:24 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 05/25] lmb: Factor the lowest level alloc function
In-Reply-To: <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
Message-ID: <alpine.LFD.2.00.1005111428470.3401@localhost.localdomain>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org> <1273484339-28911-2-git-send-email-benh@kernel.crashing.org> <1273484339-28911-3-git-send-email-benh@kernel.crashing.org> <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org> <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 May 2010, Benjamin Herrenschmidt wrote:
>  
> @@ -396,33 +406,24 @@ u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
>  	if (max_addr == LMB_ALLOC_ANYWHERE)
>  		max_addr = LMB_REAL_LIMIT;
>  
> +	/* Pump up max_addr */
> +	if (max_addr == LMB_ALLOC_ANYWHERE)
> +		max_addr = ~(u64)0;
> +	

  That if is pretty useless as you set max_addr to LMB_REAL_LIMIT
  right above.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
