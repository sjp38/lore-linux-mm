Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 769BA6B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 09:31:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u13-v6so1474358pfm.8
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 06:31:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 4-v6si1947371pgn.90.2018.08.02.06.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Aug 2018 06:31:44 -0700 (PDT)
Date: Thu, 2 Aug 2018 06:31:34 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Question] A novel case happened when using mempool allocate
 memory.
Message-ID: <20180802133134.GA11845@bombadil.infradead.org>
References: <5B61D243.9050608@huawei.com>
 <20180801153713.GA4039@bombadil.infradead.org>
 <5B62A30B.9000008@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B62A30B.9000008@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 02, 2018 at 02:22:03PM +0800, zhong jiang wrote:
> On 2018/8/1 23:37, Matthew Wilcox wrote:
> > Please post the code.
> 
> when module is loaded. we create the specific mempool. The code flow is as follows.

I actually meant "post the code you are testing", not "write out some
pseudocode".
