Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 34CC56B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 12:38:52 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so120005994wme.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 09:38:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 81si34840776wma.110.2016.02.16.09.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 09:38:51 -0800 (PST)
Date: Tue, 16 Feb 2016 09:38:49 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: add MM_SWAPENTS and page table when calculate
 tasksize in lowmem_scan()
Message-ID: <20160216173849.GA10487@kroah.com>
References: <56C2EDC1.2090509@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56C2EDC1.2090509@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, Feb 16, 2016 at 05:37:05PM +0800, Xishi Qiu wrote:
> Currently tasksize in lowmem_scan() only calculate rss, and not include swap.
> But usually smart phones enable zram, so swap space actually use ram.

Yes, but does that matter for this type of calculation?  I need an ack
from the android team before I could ever take such a core change to
this code...

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
