Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A57046B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 21:18:04 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id a14so1126284pls.8
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 18:18:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g64sor106138pfd.76.2018.02.15.18.18.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 18:18:03 -0800 (PST)
Date: Fri, 16 Feb 2018 11:17:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v1] mm: Re-use DEFINE_SHOW_ATTRIBUTE() macro
Message-ID: <20180216021756.GA5289@tigerII.localdomain>
References: <20180214154644.54505-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214154644.54505-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Dennis Zhou <dennisszhou@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On (02/14/18 17:46), Andy Shevchenko wrote:
> 
> ...instead of open coding file operations followed by custom ->open()
> callbacks per each attribute.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>


FWIW,
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
