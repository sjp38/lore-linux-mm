Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id AAA616B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:44:04 -0400 (EDT)
Date: Tue, 10 Apr 2012 16:41:37 +0300 (EEST)
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: Re: [PATCHv24 00/16] Contiguous Memory Allocator
In-Reply-To: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
Message-ID: <alpine.DEB.2.00.1204101528390.9354@kernel.research.nokia.com>
References: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Sandeep Patil <psandeep.s@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi,

On Tue, 3 Apr 2012, Marek Szyprowski wrote:
> This is (yet another) update of CMA patches.

How well CMA is supposed to work if you have mlocked processes? I've
been testing these patches, and noticed that by creating a small mlocked
process you start to get plenty of test_pages_isolated() failure warnings,
and bigger allocations will always fail.

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
