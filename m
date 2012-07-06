Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3CC286B0070
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 21:24:54 -0400 (EDT)
Message-ID: <1341537867.6330.46.camel@pasglop>
Subject: Re: [PATCH] mm: setup pageblock_order before it's used by sparse
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 06 Jul 2012 11:24:27 +1000
In-Reply-To: <CAE9FiQXAuqj5V_ZrZPs3qr93XQS1tCO=qOBP7mCsDCqXQQ5PoQ@mail.gmail.com>
References: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com>
	 <20120703140705.af23d4d3.akpm@linux-foundation.org>
	 <4FF39F0E.4070300@huawei.com> <20120704092006.GH14154@suse.de>
	 <CAE9FiQXAuqj5V_ZrZPs3qr93XQS1tCO=qOBP7mCsDCqXQQ5PoQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Thu, 2012-07-05 at 18:00 -0700, Yinghai Lu wrote:
> cma, dma_continugous_reserve is referring pageblock_order very early
> too.
> just after init_memory_mapping() for x86's setup_arch.
> 
> so set pageblock_order early looks like my -v2 patch is right way.
> 
> current question: need to powerpc guys to check who to set that early.

I missed the beginning of that discussion, I'll try to dig a bit,
might take me til next week though as I'm about to be off for
the week-end.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
