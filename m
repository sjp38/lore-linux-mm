Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 584CF6B0037
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 02:28:08 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so4635693pde.6
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 23:28:07 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id j6si4228708pdk.73.2014.07.13.23.28.06
        for <linux-mm@kvack.org>;
        Sun, 13 Jul 2014 23:28:07 -0700 (PDT)
Date: Mon, 14 Jul 2014 15:34:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 08/10] mm/page_alloc: use get_onbuddy_migratetype() to
 get buddy list type
Message-ID: <20140714063401.GD11317@js1304-P5Q-DELUXE>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1404460675-24456-9-git-send-email-iamjoonsoo.kim@lge.com>
 <53BAC37D.3060703@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BAC37D.3060703@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 07, 2014 at 05:57:49PM +0200, Vlastimil Babka wrote:
> On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> >When isolating free page, what we want to know is which list
> >the page is linked. If it is linked in isolate migratetype buddy list,
> >we can skip watermark check and freepage counting. And if it is linked
> >in CMA migratetype buddy list, we need to fixup freepage counting. For
> >this purpose, get_onbuddy_migratetype() is more fit and cheap than
> >get_pageblock_migratetype(). So use it.
> 
> Hm but you made get_onbuddy_migratetype() work only with
> CONFIG_MEMORY_ISOLATION. And __isolate_free_page is (despite the
> name) not at all limited to CONFIG_MEMORY_ISOLATION.

get_onbuddy_migratetype() is only used for determining whether this
page is on isolate buddy list or not. So if !CONFIG_MEMORY_ISOLATION,
default value of get_onbuddy_migratetype() makes things correct.

But, I should write some code comment.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
