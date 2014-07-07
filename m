Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 04FAA6B0037
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 00:53:24 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so4633683pdj.8
        for <linux-mm@kvack.org>; Sun, 06 Jul 2014 21:53:24 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id tf3si40241932pac.14.2014.07.06.21.53.22
        for <linux-mm@kvack.org>;
        Sun, 06 Jul 2014 21:53:23 -0700 (PDT)
Date: Mon, 7 Jul 2014 13:58:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 01/10] mm/page_alloc: remove unlikely macro on
 free_one_page()
Message-ID: <20140707045841.GC29236@js1304-P5Q-DELUXE>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1404460675-24456-2-git-send-email-iamjoonsoo.kim@lge.com>
 <53B697FE.1040405@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53B697FE.1040405@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 04, 2014 at 02:03:10PM +0200, Vlastimil Babka wrote:
> On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> > Isolation is really rare case so !is_migrate_isolate() is
> > likely case. Remove unlikely macro.
> 
> Good catch. Why not replace it with likely then? Any difference in the assembly?
> 

I didn't investigate it. I will check it in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
