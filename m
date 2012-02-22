Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id C15746B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 04:10:06 -0500 (EST)
Date: Wed, 22 Feb 2012 09:09:30 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv22 14/16] X86: integrate CMA with DMA-mapping subsystem
Message-ID: <20120222090930.GS22562@n2100.arm.linux.org.uk>
References: <1329507036-24362-1-git-send-email-m.szyprowski@samsung.com> <1329507036-24362-15-git-send-email-m.szyprowski@samsung.com> <20120221161802.f6a28085.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120221161802.f6a28085.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

On Tue, Feb 21, 2012 at 04:18:02PM -0800, Andrew Morton wrote:
> After a while I got it to compile for i386.  arm didn't go so well,
> partly because arm allmodconfig is presently horked (something to do
> with Kconfig not setting PHYS_OFFSET) and partly because arm defconfig
> doesn't permit CMA to be set.  Got bored, gave up.

That's not going to get fixed, unfortunately.  It requires us to find
some way to force various options to certain states on all*config
builds, because not surprisingly a value of 'y', 'm' or 'n' doesn't
work for integer or hex config options.

So the only way all*config can be used on ARM is with a seed config file
to force various options to particular states to ensure that we end up
with a sane configuration that avoids crap like that.

Alternatively, we need a way to tell kconfig that various options are to
be set in certain ways in the Kconfig files for all*config to avoid it
wanting values for hex or int options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
