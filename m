Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DA0B16B0037
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 12:58:57 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id eu11so1112509pac.37
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 09:58:57 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id hh2si32380883pbb.80.2014.09.17.09.28.54
        for <linux-mm@kvack.org>;
        Wed, 17 Sep 2014 09:28:54 -0700 (PDT)
Date: Wed, 17 Sep 2014 17:28:23 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64:free_initrd_mem should also free the memblock
Message-ID: <20140917162822.GB15261@e104818-lin.cambridge.arm.com>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB029@CNBJMBX05.corpusers.net>
 <20140915183334.GA30737@arm.com>
 <20140915184023.GF12361@n2100.arm.linux.org.uk>
 <20140915185027.GC30737@arm.com>
 <35FD53F367049845BC99AC72306C23D103D6DB49160C@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB49160C@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Will Deacon <Will.Deacon@arm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Tue, Sep 16, 2014 at 02:53:55AM +0100, Wang, Yalin wrote:
> The reason that a want merge this patch is that
> It confuse me when I debug memory issue by 
> /sys/kernel/debug/memblock/reserved  debug file,
> It show lots of un-correct reserved memory.
> In fact, I also send a patch to cma driver part
> For this issue too:
> http://ozlabs.org/~akpm/mmots/broken-out/free-the-reserved-memblock-when-free-cma-pages.patch
> 
> I want to remove these un-correct memblock parts as much as possible,
> so that I can see more correct info from /sys/kernel/debug/memblock/reserved
> debug file .

Could we not always call memblock_free() from free_reserved_area() (with
a dummy definition when !CONFIG_HAVE_MEMBLOCK)?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
