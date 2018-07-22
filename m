Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 635F36B0003
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 23:52:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x20-v6so2016564pln.13
        for <linux-mm@kvack.org>; Sat, 21 Jul 2018 20:52:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w9-v6si4949858plp.395.2018.07.21.20.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 21 Jul 2018 20:52:01 -0700 (PDT)
Date: Sat, 21 Jul 2018 20:51:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
Message-ID: <20180722035156.GA12125@bombadil.infradead.org>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org>
 <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com>
 <3238b5d2-fd89-a6be-0382-027a24a4d3ad@linux.alibaba.com>
 <alpine.DEB.2.21.1807201401390.231119@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807201401390.231119@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, hughd@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 20, 2018 at 02:05:52PM -0700, David Rientjes wrote:
> The huge zero page can be reclaimed under memory pressure and, if it is, 
> it is attempted to be allocted again with gfp flags that attempt memory 
> compaction that can become expensive.  If we are constantly under memory 
> pressure, it gets freed and reallocated millions of times always trying to 
> compact memory both directly and by kicking kcompactd in the background.
> 
> It likely should also be per node.

Have you benchmarked making the non-huge zero page per-node?
