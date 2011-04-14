Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B3475900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:34:11 -0400 (EDT)
Date: Thu, 14 Apr 2011 14:33:35 -0700 (PDT)
Message-Id: <20110414.143335.104052252.davem@davemloft.net>
Subject: Re: [PATCH 08/12] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
From: David Miller <davem@davemloft.net>
In-Reply-To: <1302777698-28237-9-git-send-email-mgorman@suse.de>
References: <1302777698-28237-1-git-send-email-mgorman@suse.de>
	<1302777698-28237-9-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 14 Apr 2011 11:41:34 +0100

> +extern int memalloc_socks;
> +static inline int sk_memalloc_socks(void)
> +{
> +	return memalloc_socks;
> +}
> +
 ...
> +static DEFINE_MUTEX(memalloc_socks_lock);
> +int memalloc_socks __read_mostly;

Please use an atomic_t, it has to be more efficient than this mutex
business.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
