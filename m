Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC408D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:08:28 -0500 (EST)
Date: Mon, 7 Mar 2011 15:07:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2] procfs: fix /proc/<pid>/maps heap check
Message-Id: <20110307150756.d50635f1.akpm@linux-foundation.org>
In-Reply-To: <1299244994-5284-1-git-send-email-aaro.koskinen@nokia.com>
References: <1299244994-5284-1-git-send-email-aaro.koskinen@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, stable@kernel.org

On Fri,  4 Mar 2011 15:23:14 +0200
Aaro Koskinen <aaro.koskinen@nokia.com> wrote:

> The current code fails to print the "[heap]" marking if the heap is
> splitted into multiple mappings.
> 
> Fix the check so that the marking is displayed in all possible cases:
> 	1. vma matches exactly the heap
> 	2. the heap vma is merged e.g. with bss
> 	3. the heap vma is splitted e.g. due to locked pages
> 
> Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
> Cc: stable@kernel.org

Why do you believe this problem is serious enough to justify
backporting the fix into -stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
