Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 782798D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 20:28:03 -0500 (EST)
Date: Mon, 7 Mar 2011 17:26:13 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] hugetlb: /proc/meminfo shows data for all sizes of
 hugepages
Message-ID: <20110308012613.GA2391@tassilo.jf.intel.com>
References: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: linux-kernel@vger.kernel.org, emunson@mgebm.net, anton@redhat.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Mon, Mar 07, 2011 at 02:05:55PM +0100, Petr Holasek wrote:
> /proc/meminfo file shows data for all used sizes of hugepages
> on system, not only for default hugepage size.

When I wrote that It was intentional to only report the 
default page size here. The other page sizes are reported
in sysfs instead.

The reason was to avoid breaking any applications that
read /proc/meminfo today.

I suspect your patch will break them.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
