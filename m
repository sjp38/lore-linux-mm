Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id BAB1A6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 19:22:04 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so337695wgh.26
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 16:22:04 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id uj9si818482wjc.132.2014.07.29.16.22.03
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 16:22:03 -0700 (PDT)
Date: Wed, 30 Jul 2014 02:21:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5 05/14] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
Message-ID: <20140729232142.GB17685@node.dhcp.inet.fi>
References: <1406553101-29326-1-git-send-email-vbabka@suse.cz>
 <1406553101-29326-6-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.02.1407281709050.8998@chino.kir.corp.google.com>
 <53D7690D.5070307@suse.cz>
 <alpine.DEB.2.02.1407291559130.20991@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407291559130.20991@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Tue, Jul 29, 2014 at 04:02:09PM -0700, David Rientjes wrote:
> Hmm, I'm confused at how that could be true, could you explain what 
> memory other than thp can return true for PageTransHuge()?

PageTransHuge() will be true for any head of compound page if THP is
enabled compile time: hugetlbfs, slab, whatever.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
