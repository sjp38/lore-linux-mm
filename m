Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 402736B0032
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 20:16:40 -0500 (EST)
Received: by paceu11 with SMTP id eu11so3960255pac.7
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 17:16:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ic7si9427995pad.236.2015.02.19.17.16.39
        for <linux-mm@kvack.org>;
        Thu, 19 Feb 2015 17:16:39 -0800 (PST)
Date: Fri, 20 Feb 2015 09:16:25 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: drivers/net/ethernet/broadcom/tg3.c:17811:37: warning: array
 subscript is above array bounds
Message-ID: <20150220011625.GA4228@wfg-t540p.sh.intel.com>
References: <201502190116.RU3JpDne%fengguang.wu@intel.com>
 <54E603B0.60505@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54E603B0.60505@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: kbuild-all@01.org, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Andrey,

On Thu, Feb 19, 2015 at 06:39:28PM +0300, Andrey Ryabinin wrote:
> On 02/18/2015 08:14 PM, kbuild test robot wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > head:   f5af19d10d151c5a2afae3306578f485c244db25
> > commit: ef7f0d6a6ca8c9e4b27d78895af86c2fbfaeedb2 x86_64: add KASan support
> > date:   5 days ago
> > config: x86_64-randconfig-iv1-02190055 (attached as .config)
> > reproduce:
> >   git checkout ef7f0d6a6ca8c9e4b27d78895af86c2fbfaeedb2
> >   # save the attached .config to linux build tree
> >   make ARCH=x86_64 
> > 
> > Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> > 
> > All warnings:
> > 
> >    drivers/net/ethernet/broadcom/tg3.c: In function 'tg3_init_one':
> >>> drivers/net/ethernet/broadcom/tg3.c:17811:37: warning: array subscript is above array bounds [-Warray-bounds]
> >       struct tg3_napi *tnapi = &tp->napi[i];
> >                                         ^
> >>> drivers/net/ethernet/broadcom/tg3.c:17811:37: warning: array subscript is above array bounds [-Warray-bounds]
> > 
> 
> This probably a GCC bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=59124
> I see this warning with 4.9.2, but not with GCC 5 where this should be fixed already.

Yes we are running gcc 4.9.2. Thank you for the info, I'll disable this warning for now.

Regards,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
