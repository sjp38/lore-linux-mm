Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id CCF606B005C
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 15:52:38 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv19 00/15] Contiguous Memory Allocator
Date: Sun, 29 Jan 2012 20:51:46 +0000
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com> <201201261531.40551.arnd@arndb.de> <20120127162624.40cba14e.akpm@linux-foundation.org>
In-Reply-To: <20120127162624.40cba14e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201201292051.46297.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Saturday 28 January 2012, Andrew Morton wrote:
> These patches don't seem to have as many acked-bys and reviewed-bys as
> I'd expect.  Given the scope and duration of this, it would be useful
> to gather these up.  But please ensure they are real ones - people
> sometimes like to ack things without showing much sign of having
> actually read them.

I reviewed early versions of this patch set and had a lot of comments on the
interfaces that were exposed to device drivers and platform maintainers.

All of the comments were addressed back then and I gave an Acked-by.
I assume that it was dropped in subsequent versions because the
implementation changed significantly since, but I'm still happy with the
way this looks to the user, in particular that it is practically invisible
because all users just go through the dma mapping API instead of the
horrors that were used in the original patches.

=46rom an ARM architecture perspective, we have come to the point (some
versions ago) where we actually require the CMA patchset for correctness,
even on IOMMU based systems because it avoids some nasty corner cases
with pages that are both in the linear kernel mapping and in an
uncached mapping for DMA: We know that the code we are using in mainline
is broken on ARMv6 and later and that CMA fixes that problem.

I'm not the right person to judge the memory management code changes,
others need to comment on that. Aside from that:

Acked-by: Arnd Bergmann <arnd@arndb.de>

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
