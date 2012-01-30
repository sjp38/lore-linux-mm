Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 57A856B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 04:16:33 -0500 (EST)
Received: by iadk27 with SMTP id k27so7115744iad.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 01:16:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <014101ccdf22$eb610d30$c2232790$%szyprowski@samsung.com>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-13-git-send-email-m.szyprowski@samsung.com>
 <CADMYwHw1B4RNV_9BqAg_M70da=g69Z3kyo5Cr6izCMwJ9LAtvA@mail.gmail.com>
 <00de01ccdce1$e7c8a360$b759ea20$%szyprowski@samsung.com> <CAO8GWqnQg-W=TEc+CUc8hs=GrdCa9XCCWcedQx34cqURhNwNwA@mail.gmail.com>
 <010301ccdd03$1ad15ab0$50741010$%szyprowski@samsung.com> <CAK=WgbZWHBKNQwcoY9OiXXH-r1n3XxB=ZODZJN-3vZopU2yhJA@mail.gmail.com>
 <010501ccdd06$b9844f20$2c8ced60$%szyprowski@samsung.com> <CAK=WgbY3L7u0AC1c=iNvoMXX+LSJoz1W-xb=S6gmhqcse5CKaA@mail.gmail.com>
 <014101ccdf22$eb610d30$c2232790$%szyprowski@samsung.com>
From: Ohad Ben-Cohen <ohad@wizery.com>
Date: Mon, 30 Jan 2012 11:16:12 +0200
Message-ID: <CAK=WgbaDpbeMGZ4eyPv6bGRFibQ8EaQ8kk5DQZ_qwDoMorD6uQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 12/15] drivers: add Contiguous Memory Allocator
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "Clark, Rob" <rob@ti.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Hi Marek,

On Mon, Jan 30, 2012 at 9:43 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> Did you managed to fix this issue?

Yes -- the recent increase in the vmalloc region triggered a bigger
truncation in the system RAM than we had before, and therefore
conflicted with the previous hardcoded region we were using.

Long term, our plan is to get rid of those hardcoded values, but for
the moment our remote RTOS still needs to know the physical address in
advance.

> Right, thanks for spotting it, I will squash it to the next release.

Thanks. With that hunk squashed in, feel free to add my Tested-by tag
to the patches.

Thanks!
Ohad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
