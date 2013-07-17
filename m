Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id C309C6B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 14:06:08 -0400 (EDT)
Date: Wed, 17 Jul 2013 14:06:03 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1374084363-9zlarbf2-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1374078950-8o0ev16q-mutt-n-horiguchi@ah.jp.nec.com>
References: <1374012587-whdyhveh-mutt-n-horiguchi@ah.jp.nec.com>
 <1374078950-8o0ev16q-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/swap.c: clear PageActive before adding pages onto
 unevictable list (Re: 3.11.0-rc1: kernel BUG at mm/migrate.c:458 in page
 migration)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kirill.shutemov@linux.intel.com

On Wed, Jul 17, 2013 at 12:35:50PM -0400, Naoya Horiguchi wrote:
...
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Wed, 17 Jul 2013 11:49:56 -0400
> Subject: [PATCH] mm/swap.c: clear PageActive before adding pages onto
>  unevictable list
> 
> As a result of v3.10-3600-g13f7f78 "mm: pagevec: defer deciding which LRU
> to add a page to until pagevec drain time," pages on unevictable lists can
> have both of PageActive and PageUnevictable set. This is not only confusing,
> but also corrupts page migration and shrink_[in]active_list.
> 
> This patch fixes the problem by adding ClearPageActive before adding pages
> into unevictable list. It also cleans up VM_BUG_ONs.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # 3.10

No need to send to stable because the problem occurs after 3.10, sorry.

Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
