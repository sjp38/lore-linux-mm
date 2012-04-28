Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id C63A76B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 12:25:12 -0400 (EDT)
Message-ID: <4F9C19DB.2050601@parallels.com>
Date: Sat, 28 Apr 2012 20:24:59 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH bugfix] proc/pagemap: correctly report non-present ptes
 and holes between vmas
References: <20120428162229.15658.56316.stgit@zurg>
In-Reply-To: <20120428162229.15658.56316.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 04/28/2012 08:22 PM, Konstantin Khlebnikov wrote:
> This patch resets current pagemap-entry if current pte isn't present,
> or if current vma is over. Otherwise pagemap reports last entry again and again.
> 
> non-present pte reporting was broken in commit v3.3-3738-g092b50b
> ("pagemap: introduce data structure for pagemap entry")
> 
> reporting for holes was broken in commit v3.3-3734-g5aaabe8
> ("pagemap: avoid splitting thp when reading /proc/pid/pagemap")
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Reported-by: Pavel Emelyanov <xemul@parallels.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andi Kleen <ak@linux.intel.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
