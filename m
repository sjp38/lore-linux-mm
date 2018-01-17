Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6265928029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 09:17:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w186so11568176pgb.10
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 06:17:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m3si3885297pgs.54.2018.01.17.06.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 06:17:14 -0800 (PST)
Date: Wed, 17 Jan 2018 06:17:04 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] mm: why vfree() do not free page table memory?
Message-ID: <20180117141704.GA10398@bombadil.infradead.org>
References: <5A4603AB.8060809@huawei.com>
 <0ffd113e-84da-bd49-2b63-3d27d2702580@suse.cz>
 <5A5F1C09.9040000@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A5F1C09.9040000@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Wujiangtao (A)" <wu.wujiangtao@huawei.com>

On Wed, Jan 17, 2018 at 05:48:57PM +0800, Xishi Qiu wrote:
> > Did you notice an actual issue, or is this just theoretical concern.
> 
> Yes, we have this problem on our production line.
> I find the page table memory takes 200-300M.

200MB?  That's mapping 800GB of virtual address space.  That must be
quite the module you're loading there ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
