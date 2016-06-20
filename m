Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1457A6B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 04:00:16 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id q11so71648944itd.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 01:00:16 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z193si5188416itb.9.2016.06.20.01.00.12
        for <linux-mm@kvack.org>;
        Mon, 20 Jun 2016 01:00:13 -0700 (PDT)
Date: Mon, 20 Jun 2016 17:00:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: update zram to use zpool
Message-ID: <20160620080021.GB28207@bbox>
References: <cover.1466000844.git.geliangtang@gmail.com>
 <efcf047e747d9d1e80af16ebfc51ea1964a7a621.1466000844.git.geliangtang@gmail.com>
 <20160615231732.GJ17127@bbox>
 <CAMJBoFPcaAbsQ=PA2WPsmuyd1a-SyJgE5k4Rn2CUf6rS0-ykKw@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CAMJBoFPcaAbsQ=PA2WPsmuyd1a-SyJgE5k4Rn2CUf6rS0-ykKw@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Jun 17, 2016 at 10:30:58AM +0200, Vitaly Wool wrote:
> Hi Minchan,
> 
> On Thu, Jun 16, 2016 at 1:17 AM, Minchan Kim <minchan@kernel.org> wrote:
> > On Wed, Jun 15, 2016 at 10:42:07PM +0800, Geliang Tang wrote:
> >> Change zram to use the zpool api instead of directly using zsmalloc.
> >> The zpool api doesn't have zs_compact() and zs_pool_stats() functions.
> >> I did the following two things to fix it.
> >> 1) I replace zs_compact() with zpool_shrink(), use zpool_shrink() to
> >>    call zs_compact() in zsmalloc.
> >> 2) The 'pages_compacted' attribute is showed in zram by calling
> >>    zs_pool_stats(). So in order not to call zs_pool_state() I move the
> >>    attribute to zsmalloc.
> >>
> >> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> >
> > NACK.
> >
> > I already explained why.
> > http://lkml.kernel.org/r/20160609013411.GA29779@bbox
> 
> This is a fair statement, to a certain extent. I'll let Geliang speak
> for himself but I am personally interested in this zram extension
> because I want it to work on MMU-less systems. zsmalloc can not handle
> that, so I want to be able to use zram over z3fold.

Could you tell me more detail? What's the usecase?

> 
> Best regards,
>    Vitaly
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
