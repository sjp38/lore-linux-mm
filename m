Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 6EC4B6B0005
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 20:48:14 -0500 (EST)
Date: Sun, 27 Jan 2013 02:48:11 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2] mm: clean up soft_offline_page()
Message-ID: <20130127014811.GL30577@one.firstfloor.org>
References: <1359176531-12583-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359176531-12583-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jan 26, 2013 at 12:02:11AM -0500, Naoya Horiguchi wrote:
> Currently soft_offline_page() is hard to maintain because it has many
> return points and goto statements. All of this mess come from get_any_page().
> This function should only get page refcount as the name implies, but it does
> some page isolating actions like SetPageHWPoison() and dequeuing hugepage.
> This patch corrects it and introduces some internal subroutines to make
> soft offlining code more readable and maintainable.
> 
> ChangeLog v2:
>   - receive returned value from __soft_offline_page and soft_offline_huge_page
>   - place __soft_offline_page after soft_offline_page to reduce the diff
>   - rebased onto mmotm-2013-01-23-17-04
>   - add comment on double checks of PageHWpoison

Ok for me if it passes mce-test

Reviewed-by: Andi Kleen <andi@firstfloor.org>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
