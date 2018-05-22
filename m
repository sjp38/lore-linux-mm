Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 057DD6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 05:40:38 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b36-v6so11899454pli.2
        for <linux-mm@kvack.org>; Tue, 22 May 2018 02:40:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 4-v6si16052905pfb.204.2018.05.22.02.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 May 2018 02:40:37 -0700 (PDT)
Date: Tue, 22 May 2018 02:40:35 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH v2 00/12] get rid of GFP_ZONE_TABLE/BAD
Message-ID: <20180522094035.GB25671@infradead.org>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng Ye <yehs2007@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>

This seems to be missing patch 1 and generally be in somewhat odd format.
Can you try to resend it with git-send-email and against current Linus'
tree?

Also I'd suggest you do cleanups like adding and using __GFP_ZONE_MASK
at the beginning of the series before doing any real changes.
