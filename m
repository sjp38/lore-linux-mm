Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 105C86B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 22:33:12 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so5454882pab.0
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 19:33:11 -0800 (PST)
Received: from kirsty.vergenet.net (kirsty.vergenet.net. [202.4.237.240])
        by mx.google.com with ESMTP id bw2si10712183pab.221.2015.01.21.19.33.10
        for <linux-mm@kvack.org>;
        Wed, 21 Jan 2015 19:33:11 -0800 (PST)
Date: Thu, 22 Jan 2015 12:33:06 +0900
From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in next-20150120 due to "mm: account pmd
 page tables to the process"
Message-ID: <20150122033306.GN31170@verge.net.au>
References: <20150121023003.GF30598@verge.net.au>
 <20150121092956.4CF89A8@black.fi.intel.com>
 <CAMuHMdWyXaxobndjYDwYwqE=XJCBH_7C9TFBZYr7UpYk-rUa4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdWyXaxobndjYDwYwqE=XJCBH_7C9TFBZYr7UpYk-rUa4A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Magnus Damm <magnus.damm@gmail.com>

On Wed, Jan 21, 2015 at 10:37:20AM +0100, Geert Uytterhoeven wrote:
> Hi Kirill, Simon,
> 
> On Wed, Jan 21, 2015 at 10:29 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Simon Horman wrote:
> >> Hi,
> >>
> >> I have observed what appears to be a regression caused
> >> by b316feb3c37ff19cd ("mm: account pmd page tables to the process").
> >>
> >> The problem that I am seeing is that when booting the kzm9g board, which is
> >> based on the Renesas r8a73a4 ARM SoC, using its defconfig the following the
> 
> Renesas sh73a0 ARM SoC, FWIW...
> 
> >> tail boot log below is output repeatedly and the boot does not appear to
> >> proceed any further.
> >>
> >> I have observed this problem using next-20150120 and observed
> >> that it does not occur when the patch mentioned above is reverted.
> >>
> >> I have also observed what appears to be the same problem when
> >> booting the following boards using their defconfigs. And perhaps
> >> more to the point the problem appears to affect booting all
> >> boards based on Renesas ARM SoCs for which there is working support
> >> to boot them by initialising them using C (as opposed to device tree).
> >>
> >> * armadillo800eva, based on the r8a7740 SoC
> >> * mackerel, based on the sh7372
> >
> > This should be fixed by this:
> >
> > http://marc.info/?l=linux-next&m=142176280218627&w=2
> >
> > Please, test.
> 
> Thanks!
> 
> Confirmed the issue, and confirmed the fix (on sh73a0/kzm9g-legacy).
> 
> Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>

Thanks, I have also tested the armadillo800eva and mackerel.

Tested-by: Simon Horman <horms+renesas@verge.net.au>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
