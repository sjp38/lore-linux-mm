Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFB6D6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 02:38:43 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so203078781pfg.4
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 23:38:43 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 126si53925040pgb.180.2016.11.27.23.38.42
        for <linux-mm@kvack.org>;
        Sun, 27 Nov 2016 23:38:42 -0800 (PST)
Date: Mon, 28 Nov 2016 16:41:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 0/6] Introduce ZONE_CMA
Message-ID: <20161128074141.GB32105@js1304-P5Q-DELUXE>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20161107062501.GB21159@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107062501.GB21159@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 07, 2016 at 03:25:01PM +0900, Joonsoo Kim wrote:
> On Fri, Oct 14, 2016 at 12:03:10PM +0900, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Hello,
> > 
> > Changes from v5
> > o Add acked/reviewed-by tag from Vlastimil and Aneesh
> > o Rebase on next-20161013
> > o Cosmetic change on patch 1
> > o Optimize span of ZONE_CMA on multiple node system
> 
> Hello, Andrew.
> 
> I got some acked/reviewed-by tags from some of main MM developers who
> are actually familiar/associated with this change. Could you merge
> this patchset to your tree to get more test coverage?
> 
> If I need to do more things to merge this patchset, please let me know
> about it.

Hello, Andrew.

Could I get your answer about this patchset?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
