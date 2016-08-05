Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19F296B025F
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:21:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so522612441pfg.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:14:43 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id q11si20826185pfd.42.2016.08.05.07.48.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 07:48:06 -0700 (PDT)
Received: from epcas2p3.samsung.com (unknown [182.195.41.55])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OBF02KA9YG49M10@mailout4.samsung.com> for linux-mm@kvack.org;
 Fri, 05 Aug 2016 23:48:04 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
In-reply-to: <20160805082015.GA28235@bbox>
Subject: RE: [linux-mm] Drastic increase in application memory usage with
 Kernel version upgrade
Date: Fri, 05 Aug 2016 20:17:36 +0530
Message-id: <01c101d1ef28$50706ad0$f1514070$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
References: 
 <CGME20160805045709epcas3p1dc6f12f2fa3031112c4da5379e33b5e9@epcas3p1.samsung.com>
 <01a001d1eed5$c50726c0$4f157440$@samsung.com> <20160805082015.GA28235@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaejoon.seo@samsung.com, jy0.jeon@samsung.com, vishnu.ps@samsung.com

Hi,
> -----Original Message-----
> From: Minchan Kim [mailto:minchan@kernel.org]
> Sent: Friday, August 05, 2016 1:50 PM
> To: PINTU KUMAR
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> jaejoon.seo@samsung.com; jy0.jeon@samsung.com; vishnu.ps@samsung.com
> Subject: Re: [linux-mm] Drastic increase in application memory usage with
Kernel
> version upgrade
> 
> On Fri, Aug 05, 2016 at 10:26:37AM +0530, PINTU KUMAR wrote:
> > Hi All,
> >
> > For one of our ARM embedded product, we recently updated the Kernel
> > version from
> > 3.4 to 3.18 and we noticed that the same application memory usage (PSS
> > value) gone up by ~10% and for some cases it even crossed ~50%.
> > There is no change in platform part. All platform component was built
> > with ARM 32-bit toolchain.
> > However, the Kernel is changed from 32-bit to 64-bit.
> >
> > Is upgrading Kernel version and moving from 32-bit to 64-bit is such a risk
?
> > After the upgrade, what can we do further to reduce the application
> > memory usage ?
> > Is there any other factor that will help us to improve without major
> > modifications in platform ?
> >
> > As a proof, we did a small experiment on our Ubuntu-32 bit machine.
> > We upgraded Ubuntu Kernel version from 3.13 to 4.01 and we observed
> > the
> > following:
> > ----------------------------------------------------------------------
> > ----------
> > -------------
> > |UBUNTU-32 bit		|Kernel 3.13	|Kernel 4.03	|DIFF	|
> > |CALCULATOR PSS	|6057 KB	|6466 KB	|409 KB	|
> > ----------------------------------------------------------------------
> > ----------
> > -------------
> > So, just by upgrading the Kernel version: PSS value for calculator is
> > increased by 409KB.
> >
> > If anybody knows any in-sight about it please point out more details
> > about the root cause.
> 
> One of culprit is [8c6e50b0290c, mm: introduce vm_ops->map_pages()].
Ok. Thank you for your reply.
So, if I revert this patch, will the memory usage be decreased for the processes
with Kernel 3.18 ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
