Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88BFD6B5911
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 17:32:57 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f13-v6so7486240pgs.15
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 14:32:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u64-v6sor3041877pgu.382.2018.08.31.14.32.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 14:32:56 -0700 (PDT)
Date: Fri, 31 Aug 2018 14:32:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v1] mm/slub.c: Switch to bitmap_zalloc()
In-Reply-To: <20180830104301.61649-1-andriy.shevchenko@linux.intel.com>
Message-ID: <alpine.DEB.2.21.1808311432390.118964@chino.kir.corp.google.com>
References: <20180830104301.61649-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 30 Aug 2018, Andy Shevchenko wrote:

> Switch to bitmap_zalloc() to show clearly what we are allocating.
> Besides that it returns pointer of bitmap type instead of opaque void *.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Tested-by: David Rientjes <rientjes@google.com>
