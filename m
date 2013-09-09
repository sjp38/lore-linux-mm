Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 10FBF6B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 15:53:42 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 9 Sep 2013 13:53:41 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id BCF143E40026
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 13:53:38 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r89JrcXK365454
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 13:53:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r89Jrc02013236
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 13:53:38 -0600
Date: Mon, 9 Sep 2013 14:53:35 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/4] mm: use mapcount for identifying zbud pages
Message-ID: <20130909195335.GF4701@variantweb.net>
References: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com>
 <1377852176-30970-3-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377852176-30970-3-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Fri, Aug 30, 2013 at 10:42:54AM +0200, Krzysztof Kozlowski wrote:
> Currently zbud pages do not have any flags set so it is not possible to
> identify them during migration or compaction.
> 
> Implement PageZbud() by comparing page->_mapcount to -127 to distinguish
> pages allocated by zbud. Just like PageBuddy() is implemented.
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

> ---
>  include/linux/mm.h |   23 +++++++++++++++++++++++
>  mm/zbud.c          |    4 ++++
>  2 files changed, 27 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
