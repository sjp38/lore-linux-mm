Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 44B7A8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:11:06 -0500 (EST)
Date: Thu, 24 Feb 2011 14:10:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] hugetlbfs: correct handling of negative input to
 /proc/sys/vm/nr_hugepages
Message-Id: <20110224141034.d2dfb7de.akpm@linux-foundation.org>
In-Reply-To: <4D6419C0.8080804@redhat.com>
References: <4D6419C0.8080804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Tue, 22 Feb 2011 21:17:04 +0100
Petr Holasek <pholasek@redhat.com> wrote:

> When user insert negative value into /proc/sys/vm/nr_hugepages it will 
> result
> in the setting a random number of HugePages in system

Is this true?  afacit the kernel will allocate as many pages as it can
and will then set /proc/sys/vm/nr_hugepages to reflect the result. 
That's not random.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
