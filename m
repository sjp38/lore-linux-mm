Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CCE226B0078
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 16:41:50 -0400 (EDT)
Date: Wed, 22 Sep 2010 15:41:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 01/10] hugetlb: fix metadata corruption in
 hugetlb_fault()
In-Reply-To: <20100920104723.GG1998@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009221541350.32661@router.home>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100920104723.GG1998@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Reviewed-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
