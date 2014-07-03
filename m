Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 87A0E6B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 21:01:59 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id 10so8649702lbg.1
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 18:01:58 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id w1si23317457laa.1.2014.07.02.18.01.56
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 18:01:58 -0700 (PDT)
Date: Thu, 3 Jul 2014 10:03:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v9] mm: support madvise(MADV_FREE)
Message-ID: <20140703010318.GA2939@bbox>
References: <1404174975-22019-1-git-send-email-minchan@kernel.org>
 <20140701145058.GA2084@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140701145058.GA2084@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Hello,

On Tue, Jul 01, 2014 at 05:50:58PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jul 01, 2014 at 09:36:15AM +0900, Minchan Kim wrote:
> > +	do {
> > +		/*
> > +		 * XXX: We can optimize with supporting Hugepage free
> > +		 * if the range covers.
> > +		 */
> > +		next = pmd_addr_end(addr, end);
> > +		if (pmd_trans_huge(*pmd))
> > +			split_huge_page_pmd(vma, addr, pmd);
> 
> Could you implement proper THP support before upstreaming the feature?
> It shouldn't be a big deal.

Okay, Hope to review.

Thanks for the feedback!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
