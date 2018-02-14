Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC7826B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:04:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c62so5740067pfk.21
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 08:04:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z20-v6si1264479plo.73.2018.02.14.08.04.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 08:04:13 -0800 (PST)
Date: Wed, 14 Feb 2018 08:04:09 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1] mm: Re-use DEFINE_SHOW_ATTRIBUTE() macro
Message-ID: <20180214160409.GA25747@bombadil.infradead.org>
References: <20180214154644.54505-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214154644.54505-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Dennis Zhou <dennisszhou@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Feb 14, 2018 at 05:46:44PM +0200, Andy Shevchenko wrote:
> ...instead of open coding file operations followed by custom ->open()
> callbacks per each attribute.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
