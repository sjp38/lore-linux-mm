Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BAEBB6B004A
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 13:22:52 -0400 (EDT)
Date: Thu, 23 Sep 2010 11:54:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 05/10] HWPOISON, hugetlb: add free check to
 dequeue_hwpoison_huge_page()
In-Reply-To: <1283908781-13810-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1009231154500.32567@router.home>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-6-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Reviewed-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
