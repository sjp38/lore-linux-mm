Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D892828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:36:46 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i64so70230339ith.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:36:46 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l5si16846918ioe.59.2016.08.05.01.19.04
        for <linux-mm@kvack.org>;
        Fri, 05 Aug 2016 01:19:05 -0700 (PDT)
Date: Fri, 5 Aug 2016 17:20:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [linux-mm] Drastic increase in application memory usage with
 Kernel version upgrade
Message-ID: <20160805082015.GA28235@bbox>
References: <CGME20160805045709epcas3p1dc6f12f2fa3031112c4da5379e33b5e9@epcas3p1.samsung.com>
 <01a001d1eed5$c50726c0$4f157440$@samsung.com>
MIME-Version: 1.0
In-Reply-To: <01a001d1eed5$c50726c0$4f157440$@samsung.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaejoon.seo@samsung.com, jy0.jeon@samsung.com, vishnu.ps@samsung.com

On Fri, Aug 05, 2016 at 10:26:37AM +0530, PINTU KUMAR wrote:
> Hi All,
> 
> For one of our ARM embedded product, we recently updated the Kernel version from
> 3.4 to 3.18 and we noticed that the same application memory usage (PSS value)
> gone up by ~10% and for some cases it even crossed ~50%.
> There is no change in platform part. All platform component was built with ARM
> 32-bit toolchain.
> However, the Kernel is changed from 32-bit to 64-bit.
> 
> Is upgrading Kernel version and moving from 32-bit to 64-bit is such a risk ?
> After the upgrade, what can we do further to reduce the application memory usage
> ?
> Is there any other factor that will help us to improve without major
> modifications in platform ?
> 
> As a proof, we did a small experiment on our Ubuntu-32 bit machine.
> We upgraded Ubuntu Kernel version from 3.13 to 4.01 and we observed the
> following:
> --------------------------------------------------------------------------------
> -------------
> |UBUNTU-32 bit		|Kernel 3.13	|Kernel 4.03	|DIFF	|
> |CALCULATOR PSS	|6057 KB	|6466 KB	|409 KB	|
> --------------------------------------------------------------------------------
> -------------
> So, just by upgrading the Kernel version: PSS value for calculator is increased
> by 409KB.
> 
> If anybody knows any in-sight about it please point out more details about the
> root cause.

One of culprit is [8c6e50b0290c, mm: introduce vm_ops->map_pages()].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
