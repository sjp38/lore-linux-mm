Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id DD9BF82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 04:59:23 -0400 (EDT)
Received: by iofz202 with SMTP id z202so50165119iof.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 01:59:23 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id rt3si10516807igb.71.2015.10.21.01.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 01:59:23 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so49269215pad.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 01:59:23 -0700 (PDT)
Date: Wed, 21 Oct 2015 17:59:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] fixup! mm: simplify reclaim path for MADV_FREE
Message-ID: <20151021085920.GC23631@bbox>
References: <56273fe6.c8afc20a.628d8.ffff9ed8@mx.google.com>
 <5799761.gmbM76C6JW@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5799761.gmbM76C6JW@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: kernel-build-reports@lists.linaro.org, "kernelci. org bot" <bot@kernelci.org>, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Arnd,

On Wed, Oct 21, 2015 at 10:47:16AM +0200, Arnd Bergmann wrote:
> On Wednesday 21 October 2015 00:33:58 kernelci. org bot wrote:
> > lpc18xx_defconfig (arm) a?? FAIL, 55 errors, 18 warnings, 0 section mismatches
> > 
> > Errors:
> >     include/linux/rmap.h:274:1: error: expected declaration specifiers or '...' before '{' token
> >     include/linux/uaccess.h:88:13: error: storage class specified for parameter '__probe_kernel_read'
> >     include/linux/uaccess.h:99:53: error: storage class specified for parameter 'probe_kernel_write'
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: e4f28388eb72 ("mm: simplify reclaim path for MADV_FREE")

Thanks for looking at this!
FYI, Andrew already sent a patch. https://lkml.org/lkml/2015/10/21/49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
