Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3736B00AA
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 21:17:32 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1929141pab.0
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 18:17:31 -0800 (PST)
Received: from psmtp.com ([74.125.245.121])
        by mx.google.com with SMTP id yj4si21994747pac.50.2013.11.12.18.09.24
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 18:09:54 -0800 (PST)
Date: Tue, 12 Nov 2013 19:09:18 -0700
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 04/24] mm/block: remove unnecessary inclusion of bootmem.h
Message-ID: <20131113020918.GA25143@kernel.dk>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
 <1383954120-24368-5-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383954120-24368-5-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Nov 08 2013, Santosh Shilimkar wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> 
> Clean-up to remove depedency with bootmem headers.

Thanks, cleaned up for after merge window inclusion. Changed the wording
to make it more correct and fixed the spelling error:

block: cleanup removing dependency on bootmem headers

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
