Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2226B0271
	for <linux-mm@kvack.org>; Mon, 10 May 2010 11:40:10 -0400 (EDT)
Date: Mon, 10 May 2010 17:39:48 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 03/25] lmb: Introduce for_each_lmb() and new accessors,
 and use it
In-Reply-To: <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
Message-ID: <alpine.LFD.2.00.1005101735560.3401@localhost.localdomain>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org> <1273484339-28911-2-git-send-email-benh@kernel.crashing.org> <1273484339-28911-3-git-send-email-benh@kernel.crashing.org> <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 May 2010, Benjamin Herrenschmidt wrote:
>  
> +#define for_each_lmb(lmb_type, region)					\
> +	for (reg = lmb.lmb_type.regions;				\
> +	     region < (lmb.lmb_type.regions + lmb.lmb_type.cnt);	\
> +	     region++)
> +

Can you please make this:

#define for_each_lmb(lmb_type, region, __iter)				\
	for (__iter = lmb.lmb_type.regions;				\
	     region < (lmb.lmb_type.regions + lmb.lmb_type.cnt);	\
	     region++)

so we do not have the iterator name hardcoded inside the macro body.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
