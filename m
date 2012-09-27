Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 2DA276B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 21:21:03 -0400 (EDT)
Date: Thu, 27 Sep 2012 09:20:57 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v4] kpageflags: fix wrong KPF_THP on non-huge compound
 pages
Message-ID: <20120927012057.GE7205@localhost>
References: <1348691234-31729-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348691234-31729-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andi Kleen <andi.kleen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> -	else if (PageTransCompound(page))
> +	/*
> +	 * PageTransCompound can be true for non-huge compound pages (slab
> +	 * pages or pages allocated by drivers with __GFP_COMP) because it
> +	 * just checks PG_head/PG_tail, so we need to check PageLRU to make
> +	 * sure a given page is a thp, not a non-huge compound page.
> +	 */
> +	else if (PageTransCompound(page) && PageLRU(compound_trans_head(page)))
>  		u |= 1 << KPF_THP;

Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
