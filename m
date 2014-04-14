Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id F23816B00C7
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 20:07:58 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id uo5so7531431pbc.18
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 17:07:58 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id tv5si7800703pbc.502.2014.04.13.17.07.56
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 17:07:58 -0700 (PDT)
Date: Mon, 14 Apr 2014 09:08:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 0/7] Page I/O
Message-ID: <20140414000831.GA30991@bbox>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, willy@linux.intel.com

On Sun, Apr 13, 2014 at 06:59:49PM -0400, Matthew Wilcox wrote:
> Hi Andrew,
> 
> Now that 3.15-rc1 is out, could you queue these patches for 3.16 please?
> Patches 1-3 & 7 are, IMO, worthwhile cleanups / bug fixes, regardless
> of the rest of the patch set.
> 
> If this patch series gets in, I'll take care of including the NVMe
> driver piece.  It'll be a bit more tricky than the proof of concept that
> I've been flashing around because we have to make sure that the device
> responds better to page sized I/Os than accumulating larger I/Os.
> 
> It's indisputably a win for brd and for other NVM technology devices
> that are accessed synchronously rather than through DMA.

FYI, It would be good for zram, too.
I support this patchset.

>-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
