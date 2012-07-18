Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 9ACAD6B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 03:17:22 -0400 (EDT)
Message-ID: <1342595820.3669.71.camel@pasglop>
Subject: Re: [PATCH] mm: setup pageblock_order before it's used by sparse
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 18 Jul 2012 17:17:00 +1000
In-Reply-To: <4FF26726.8010904@huawei.com>
References: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com>
	 <CAE9FiQWzfLkeQs8O22MUEmuGUx=jPi5s=wZt2fcpFMcwrzt3uA@mail.gmail.com>
	 <4FF100F0.9050501@huawei.com>
	 <CAE9FiQXpeGFfWvUHHW_GjgTg+4Op7agsht5coZbcmn2W=f9bqw@mail.gmail.com>
	 <4FF25EFA.1080004@huawei.com>
	 <CAE9FiQVxY9E3L_xmRj10+9D6NVbKaxaAd2oJ6EFe1D+Gy2971w@mail.gmail.com>
	 <4FF26726.8010904@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tony Luck <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>, David Gibson <david@gibson.dropbear.id.au>, linuxppc-dev@lists.ozlabs.org

On Tue, 2012-07-03 at 11:29 +0800, Jiang Liu wrote:
> OK, waiting response from PPC. If we could find some ways to set
> HPAGE_SIZE
> early on PPC too, we can setup pageblock_order in arch instead of
> page_alloc.c
> as early as possible. 

We could split our hugetlbpage_init() into two, with the bit that sets
HPAGE_SHIFT called earlier if it's really an issue.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
