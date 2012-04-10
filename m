Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 59FD26B007E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 13:20:40 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so28758bkw.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2012 10:20:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1204101528390.9354@kernel.research.nokia.com>
References: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com> <alpine.DEB.2.00.1204101528390.9354@kernel.research.nokia.com>
From: Sandeep Patil <psandeep.s@gmail.com>
Date: Tue, 10 Apr 2012 10:19:56 -0700
Message-ID: <CA+K6fF5TbhYX_XYXL33h5s8cnSogSna4Cq2-vM4MfX4igSyozg@mail.gmail.com>
Subject: Re: [PATCHv24 00/16] Contiguous Memory Allocator
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

>>
>> This is (yet another) update of CMA patches.
>
>
> How well CMA is supposed to work if you have mlocked processes? I've
> been testing these patches, and noticed that by creating a small mlocked
> process you start to get plenty of test_pages_isolated() failure warnings,
> and bigger allocations will always fail.

CMIIW, I think mlocked pages are never migrated. The reason is because
__isolate_lru_pages() does not isolate Unevictable pages right now.

Minchan added support to allow this but the patch was dropped.

See the discussion at : https://lkml.org/lkml/2011/8/29/295

Sandeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
