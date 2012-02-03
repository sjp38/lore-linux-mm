Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 936CF6B13F2
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 09:09:06 -0500 (EST)
Date: Fri, 3 Feb 2012 14:09:02 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCHv20 00/15] Contiguous Memory Allocator
Message-ID: <20120203140902.GH5796@csn.ul.ie>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

On Fri, Feb 03, 2012 at 01:18:43PM +0100, Marek Szyprowski wrote:
> Welcome everyone again!
> 
> This is yet another quick update on Contiguous Memory Allocator patches.
> This version includes another set of code cleanups requested by Mel
> Gorman and a few minor bug fixes. I really hope that this version will
> be accepted for merging and future development will be handled by
> incremental patches.

FWIW, I've acked all I'm going to ack of this series and made some
suggestions on follow-ups on the core MM parts that could be done
in-tree. I think the current reclaim logic is going to burn CMA with
race conditions but it is a CMA-specific problem so watch out for
that :)

As before, I did not even look at the CMA driver itself or the
arch-specific parts. I'm assuming Arnd has that side of things covered.

Thanks Marek.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
