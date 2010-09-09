Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC836B0089
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 18:58:49 -0400 (EDT)
Date: Fri, 10 Sep 2010 07:56:57 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/10] Hugepage migration (v5)
Message-ID: <20100909225657.GA2790@spritzera.linux.bs1.fc.nec.co.jp>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100909123306.32134d5e@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100909123306.32134d5e@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 09, 2010 at 12:33:06PM +0200, Andi Kleen wrote:
> 
> I went over this patchkit again and it all looks good to me.
> I plan to merge it through my hwpoison tree.

Thank you.

> As far as I understand all earlier comments have been addressed
> with this revision, correct?

Yes. I've reflected all given comments.

> I am considering to fast track 10/10 (the page-types fix). 
> 
> I think the other bug fixes in the series are only for bugs added
> earlier in the series, correct?

Correct.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
