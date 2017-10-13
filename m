Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82FE06B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 21:20:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q4so13398977qtq.16
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 18:20:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x3sor11064698qkd.62.2017.10.12.18.20.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 18:20:53 -0700 (PDT)
Date: Thu, 12 Oct 2017 21:20:50 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: RE: [PATCH v6 1/4] cramfs: direct memory access support
In-Reply-To: <SG2PR06MB1165E92262CE88C704AE5ED48A4B0@SG2PR06MB1165.apcprd06.prod.outlook.com>
Message-ID: <nycvar.YSQ.7.76.1710122113250.1718@knanqh.ubzr>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org> <20171012061613.28705-2-nicolas.pitre@linaro.org> <SG2PR06MB1165E92262CE88C704AE5ED48A4B0@SG2PR06MB1165.apcprd06.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Brandt <Chris.Brandt@renesas.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 12 Oct 2017, Chris Brandt wrote:

> On Thursday, October 12, 2017, Nicolas Pitre wrote:
> > Small embedded systems typically execute the kernel code in place (XIP)
> > directly from flash to save on precious RAM usage. This adds the ability
> > to consume filesystem data directly from flash to the cramfs filesystem
> > as well. Cramfs is particularly well suited to this feature as it is
> > very simple and its RAM usage is already very low, and with this feature
> > it is possible to use it with no block device support and even lower RAM
> > usage.
> > 
> 
> Works!
> 
> I first applied the MTD patch series from here:
> 
> http://patchwork.ozlabs.org/project/linux-mtd/list/?series=7504
> 
> Then this v6 patch series on top of it.
> 
> I created a mtd-rom/direct-mapped partition and was able to both mount after boot, and also boot as the rootfs.
> 
> So far, so good.
> 
> Thank you!
> 
> Tested-by: Chris Brandt <chris.brandt@renesas.com>

Great! Thanks for testing.

Hopefully this series has finally addressed all objections that were 
raised.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
