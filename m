Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 9733B6B00A9
	for <linux-mm@kvack.org>; Wed,  8 May 2013 01:30:28 -0400 (EDT)
Message-ID: <5189E39A.4040202@cn.fujitsu.com>
Date: Wed, 08 May 2013 13:33:14 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 3/5] mm: get_user_pages: use NON-MOVABLE pages when
 FOLL_DURABLE flag is set
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com> <1362466679-17111-4-git-send-email-m.szyprowski@samsung.com> <51875977.4090006@cn.fujitsu.com> <5188DBCF.6040104@samsung.com>
In-Reply-To: <5188DBCF.6040104@samsung.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hi Marek,

On 05/07/2013 06:47 PM, Marek Szyprowski wrote:
>
> I don't think that there was any conclusion after my patch, so I really see
> no point in submitting it again now. If you need it for Your patchset, You
> can include it directly. Just please keep my signed-off-by tag.
>

That's very kind of you. I'll keep you as the Author and your 
signed-off-by tag
if I use your patches, and will cc you.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
