Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id DB8776B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 09:56:27 -0500 (EST)
Received: by iadk27 with SMTP id k27so3116469iad.14
        for <linux-mm@kvack.org>; Fri, 27 Jan 2012 06:56:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <00de01ccdce1$e7c8a360$b759ea20$%szyprowski@samsung.com>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-13-git-send-email-m.szyprowski@samsung.com>
 <CADMYwHw1B4RNV_9BqAg_M70da=g69Z3kyo5Cr6izCMwJ9LAtvA@mail.gmail.com> <00de01ccdce1$e7c8a360$b759ea20$%szyprowski@samsung.com>
From: Ohad Ben-Cohen <ohad@wizery.com>
Date: Fri, 27 Jan 2012 16:56:07 +0200
Message-ID: <CAK=WgbY+TgjWcaKcEV-c6cQPN9qbjcmNzjEsTXXCjKoOZhO7FQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 12/15] drivers: add Contiguous Memory Allocator
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2012/1/27 Marek Szyprowski <m.szyprowski@samsung.com>:
> I've tested it with 256MiB on Exynos4 platform. Could you check if the
> problem also appears on 3.2-cma-v19 branch (I've uploaded it a few hours
> ago)

Exactly what I needed, thanks :)

Both v18 and v19 seem to work fine with 3.2.

> The above code has not been changed since v16, so I'm really surprised
> that it causes problems. Maybe the memory configuration or layout has
> been changed in 3.3-rc1 for OMAP4?

Not sure what the culprit is, but it is only triggered with 3.3-rc1.

I'll tell you if I find anything.

Thanks!
Ohad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
