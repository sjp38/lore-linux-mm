Subject: Re: make swappiness safer to use
In-Reply-To: Your message of "Tue, 7 Aug 2007 13:00:33 +0800"
	<20070807050032.GA16179@mail.ustc.edu.cn>
References: <20070807050032.GA16179@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20071112020748.4B9791C745A@siro.lan>
Date: Mon, 12 Nov 2007 11:07:47 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: fengguang.wu@gmail.com
Cc: akpm@linux-foundation.org, andrea@suse.de, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

> +		/*
> +		 * Reduce the effect of imbalance if swappiness is low,
> +		 * this means for a swappiness very low, the imbalance
> +		 * must be much higher than 100 for this logic to make
> +		 * the difference.
> +		 *
> +		 * Max temporary value is vm_total_pages*100.
> +		 */
> +		imbalance *= (vm_swappiness + 1);
> +		imbalance /= 100;

why vm_swappiness rather than sc->swappiness?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
