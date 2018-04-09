Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 257146B0008
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 09:51:11 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t1-v6so7063513plb.5
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 06:51:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o6si281386pgs.51.2018.04.09.06.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 06:51:10 -0700 (PDT)
Date: Mon, 9 Apr 2018 06:51:04 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409135104.GA23434@infradead.org>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409124852.GE21835@dhcp22.suse.cz>
 <20180409134114.GA30963@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409134114.GA30963@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Chao Yu <yuchao0@huawei.com>, Minchan Kim <minchan@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 06:41:14AM -0700, Matthew Wilcox wrote:
> It's worth noting that this is endemic in filesystems.

For the rationale in XFS take a look at commit ad22c7a043c2cc6792820e6c5da699935933e87d
