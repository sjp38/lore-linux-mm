Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1756B006E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 16:24:45 -0500 (EST)
Received: by pablj1 with SMTP id lj1so23241840pab.9
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:24:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pu5si5138896pbb.254.2015.02.27.13.24.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 13:24:44 -0800 (PST)
Date: Fri, 27 Feb 2015 13:24:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: cma: fix CMA aligned offset calculation
Message-Id: <20150227132443.e17d574d45451f10f413f065@linux-foundation.org>
In-Reply-To: <1424821185-16956-1-git-send-email-dpetigara@broadcom.com>
References: <1424821185-16956-1-git-send-email-dpetigara@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Danesh Petigara <dpetigara@broadcom.com>
Cc: m.szyprowski@samsung.com, mina86@mina86.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, laurent.pinchart+renesas@ideasonboard.com, gregory.0xf0@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, 24 Feb 2015 15:39:45 -0800 Danesh Petigara <dpetigara@broadcom.com> wrote:

> The CMA aligned offset calculation is incorrect for
> non-zero order_per_bit values.
> 
> For example, if cma->order_per_bit=1, cma->base_pfn=
> 0x2f800000 and align_order=12, the function returns
> a value of 0x17c00 instead of 0x400.
> 
> This patch fixes the CMA aligned offset calculation.

When fixing a bug please always describe the end-user visible effects
of that bug.

Without that information others are unable to understand why you are
recommending a -stable backport.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
