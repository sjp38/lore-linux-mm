Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 791ED6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 08:46:06 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
Date: Fri, 17 Jun 2011 14:45:09 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <201106160006.07742.arnd@arndb.de> <20110616170133.GC28032@labbmf-linux.qualcomm.com>
In-Reply-To: <20110616170133.GC28032@labbmf-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106171445.09567.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Zach Pfeffer' <zach.pfeffer@linaro.org>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Daniel Stone' <daniels@collabora.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Thursday 16 June 2011 19:01:33 Larry Bassel wrote:
> > Can you describe how the memory areas differ specifically?
> > Is there one that is always faster but very small, or are there
> > just specific circumstances under which some memory is faster than
> > another?
> 
> One is always faster, but very small (generally 2-10% the size
> of "normal" memory).
> 

Ok, that sounds like the "SRAM" regions that we are handling on some
ARM platforms using the various interfaces. It should probably
remain outside of the regular allocator, but we can try to generalize
the SRAM support further. There are many possible uses for it.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
